#!/usr/bin/env python3
"""Generate a derived view of canonical service relationship metadata.

The Markdown front matter on service pages remains the source of truth. This
tool renders that metadata as either GitHub-rendered Mermaid Markdown or DOT
for optional Graphviz SVG/PDF rendering.
"""

from __future__ import annotations

import argparse
import html
import re
import sys
from dataclasses import dataclass
from pathlib import Path


SCRIPT_DIR = Path(__file__).resolve().parent
RELATIONSHIPS_DIR = SCRIPT_DIR.parent
SERVICES_DIR = RELATIONSHIPS_DIR.parent / "services"
DEFAULT_MARKDOWN_OUTPUT = RELATIONSHIPS_DIR / "service-graph.md"
DEFAULT_DOT_OUTPUT = RELATIONSHIPS_DIR / "service-graph.dot"
FOCUSED_GRAPHS = (
    ("Monitoring and response", "cloudwatch"),
    ("Audit paths", "cloudtrail"),
    ("Security findings", "securityhub"),
    ("Data protection", "kms"),
)


@dataclass(frozen=True)
class Edge:
    source: str
    relation: str
    target: str


@dataclass(frozen=True)
class Node:
    identifier: str
    title: str
    domains: tuple[int, ...]
    edges: tuple[Edge, ...]


class GraphError(ValueError):
    """Raised when canonical service metadata cannot form a graph."""


def front_matter(path: Path) -> tuple[str, str]:
    text = path.read_text(encoding="utf-8")
    match = re.match(r"^---\n(.*?)\n---\n(.*)$", text, re.DOTALL)
    if not match:
        raise GraphError(f"{path}: missing YAML front matter")
    return match.group(1), match.group(2)


def metadata_value(metadata: str, field: str, path: Path) -> str:
    match = re.search(rf'^{re.escape(field)}:\s*"?([^"\n]+?)"?\s*$', metadata, re.MULTILINE)
    if not match:
        raise GraphError(f"{path}: missing {field}")
    return match.group(1)


def parse_domains(metadata: str, path: Path) -> tuple[int, ...]:
    match = re.search(r"^domains:\s*\[([^]]*)\]\s*$", metadata, re.MULTILINE)
    if not match:
        raise GraphError(f"{path}: missing domains")
    try:
        domains = tuple(int(value.strip()) for value in match.group(1).split(",") if value.strip())
    except ValueError as error:
        raise GraphError(f"{path}: domains must contain integers") from error
    if not domains:
        raise GraphError(f"{path}: domains cannot be empty")
    return domains


def parse_edges(metadata: str, source: str, path: Path) -> tuple[Edge, ...]:
    lines = metadata.splitlines()
    try:
        start = lines.index("related:") + 1
    except ValueError:
        return ()

    edges: list[Edge] = []
    index = start
    while index < len(lines) and lines[index].startswith("  - "):
        relation_match = re.fullmatch(r'  - relation:\s+"?([^"\n]+?)"?\s*', lines[index])
        if not relation_match or index + 1 >= len(lines):
            raise GraphError(f"{path}: malformed related entry on line {index + 1}")
        target_match = re.fullmatch(r'    target:\s+"?([^"\n]+?)"?\s*', lines[index + 1])
        if not target_match:
            raise GraphError(f"{path}: related entry on line {index + 1} has no target")
        edges.append(Edge(source, relation_match.group(1), target_match.group(1)))
        index += 2
    return tuple(edges)


def parse_node(path: Path) -> Node:
    metadata, body = front_matter(path)
    identifier = metadata_value(metadata, "id", path)
    title_match = re.search(r"^#\s+(.+?)\s*$", body, re.MULTILINE)
    if not title_match:
        raise GraphError(f"{path}: missing H1 title")
    return Node(identifier, title_match.group(1), parse_domains(metadata, path), parse_edges(metadata, identifier, path))


def read_graph() -> tuple[Node, ...]:
    nodes = tuple(sorted((parse_node(path) for path in SERVICES_DIR.glob("*/README.md")), key=lambda node: node.identifier))
    if not nodes:
        raise GraphError(f"no canonical service pages found in {SERVICES_DIR}")
    identifiers = [node.identifier for node in nodes]
    duplicates = sorted({identifier for identifier in identifiers if identifiers.count(identifier) > 1})
    if duplicates:
        raise GraphError(f"duplicate service IDs: {', '.join(duplicates)}")
    known = set(identifiers)
    unresolved = sorted(
        f"{edge.source} --{edge.relation}--> {edge.target}"
        for node in nodes
        for edge in node.edges
        if edge.target not in known
    )
    if unresolved:
        raise GraphError(f"unresolved relationship targets:\n" + "\n".join(unresolved))
    return nodes


def mermaid_id(identifier: str) -> str:
    return "node_" + re.sub(r"[^a-zA-Z0-9_]", "_", identifier)


def all_edges(nodes: tuple[Node, ...]) -> tuple[Edge, ...]:
    return tuple(edge for node in nodes for edge in node.edges)


def focused_graph(nodes: tuple[Node, ...], identifier: str) -> tuple[tuple[Node, ...], tuple[Edge, ...]]:
    node_by_id = {node.identifier: node for node in nodes}
    if identifier not in node_by_id:
        raise GraphError(f"unknown service ID: {identifier}")
    edges = node_by_id[identifier].edges
    visible = {identifier, *(edge.target for edge in edges)}
    return tuple(node for node in nodes if node.identifier in visible), edges


def render_mermaid_diagram(nodes: tuple[Node, ...], edges: tuple[Edge, ...]) -> list[str]:
    lines = ["```mermaid", "flowchart LR"]
    for node in nodes:
        label = html.escape(node.title, quote=True)
        domains = ", ".join(str(domain) for domain in node.domains)
        lines.append(f'  {mermaid_id(node.identifier)}["{label}<br/>Domains: {domains}"]')
    for edge in edges:
        relation = edge.relation.replace("-", " ")
        lines.append(f"  {mermaid_id(edge.source)} -->|{relation}| {mermaid_id(edge.target)}")
    lines.extend(["```", ""])
    return lines


def render_mermaid_atlas(nodes: tuple[Node, ...]) -> str:
    edge_count = len(all_edges(nodes))
    lines = [
        "<!-- Generated by tools/generate-service-graph.py; do not edit manually. -->",
        "# Service relationship atlas",
        "",
        "> [!NOTE]",
        "> This is a derived view of canonical service front matter. The four focused diagrams favor readable study paths over an unreadable all-edges chart; do not use this file as the source of truth.",
        "",
        f"{len(nodes)} canonical service nodes and {edge_count} directed, typed relationships.",
        "",
        "Each arrow reads left to right: `source --relation--> target`. Only outgoing edges from the named hub are included in each focused view.",
        "",
        "## Regenerate",
        "",
        "```bash",
        "mise run graph:generate",
        "mise run graph:check",
        "```",
        "",
    ]
    for title, identifier in FOCUSED_GRAPHS:
        focused_nodes, edges = focused_graph(nodes, identifier)
        lines.extend(
            [
                f"## {title}",
                "",
                f"[Open the static SVG](service-graph-{identifier}.svg) ({len(focused_nodes)} nodes, {len(edges)} edges).",
                "",
                *render_mermaid_diagram(focused_nodes, edges),
            ]
        )
    return "\n".join(lines)


def dot_quote(value: str) -> str:
    return value.replace("\\", "\\\\").replace('"', '\\"')


def render_dot(nodes: tuple[Node, ...], edges: tuple[Edge, ...], name: str) -> str:
    lines = [
        "// Generated by tools/generate-service-graph.py; do not edit manually.",
        f"digraph {name} {{",
        '  graph [rankdir="LR", overlap="false", splines="polyline", nodesep="0.65", ranksep="1.25"];',
        '  node [shape="box", style="rounded", fontname="Arial"];',
        '  edge [fontname="Arial", fontsize="10"];',
    ]
    for node in nodes:
        domains = ", ".join(str(domain) for domain in node.domains)
        lines.append(f'  {mermaid_id(node.identifier)} [label="{dot_quote(node.title)}\\nDomains: {domains}"];')
    for edge in edges:
        lines.append(
            f'  {mermaid_id(edge.source)} -> {mermaid_id(edge.target)} '
            f'[label="{dot_quote(edge.relation)}"];'
        )
    lines.extend(["}", ""])
    return "\n".join(lines)


def arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--format", choices=("mermaid", "dot"), default="mermaid", help="output format (default: mermaid)")
    parser.add_argument("--focus", help="render outgoing edges from one canonical service ID")
    parser.add_argument("--output", type=Path, help="output path (default depends on --format)")
    parser.add_argument("--check", action="store_true", help="fail if the existing output differs from the generated graph")
    return parser.parse_args()


def main() -> int:
    args = arguments()
    try:
        nodes = read_graph()
        focused_nodes, focused_edges = focused_graph(nodes, args.focus) if args.focus else (nodes, all_edges(nodes))
    except GraphError as error:
        print(f"ERROR: {error}", file=sys.stderr)
        return 1
    if args.output:
        output = args.output
    elif args.format == "mermaid":
        output = DEFAULT_MARKDOWN_OUTPUT
    elif args.focus:
        output = RELATIONSHIPS_DIR / f"service-graph-{args.focus}.dot"
    else:
        output = DEFAULT_DOT_OUTPUT
    rendered = (
        render_mermaid_atlas(nodes)
        if args.format == "mermaid" and not args.focus
        else "\n".join(render_mermaid_diagram(focused_nodes, focused_edges))
        if args.format == "mermaid"
        else render_dot(focused_nodes, focused_edges, f"service_relationships_{args.focus or 'all'}")
    )
    if args.check:
        if not output.exists() or output.read_text(encoding="utf-8") != rendered:
            print(f"OUT OF DATE: {output}", file=sys.stderr)
            return 1
        print(f"Graph is current: {output}")
        return 0
    output.write_text(rendered, encoding="utf-8")
    print(f"Wrote {len(focused_nodes)} nodes and {len(focused_edges)} edges to {output}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
