#!/usr/bin/env python3
from __future__ import annotations

import argparse
import math
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Dict, List, Optional, Sequence, Tuple

Vec = Tuple[float, float, float]
Mat = List[List[float]]  # 4x4


# -----------------------------
# Linear algebra helpers
# -----------------------------

def vadd(a: Vec, b: Vec) -> Vec:
    return (a[0] + b[0], a[1] + b[1], a[2] + b[2])


def vsub(a: Vec, b: Vec) -> Vec:
    return (a[0] - b[0], a[1] - b[1], a[2] - b[2])


def vmul(a: Vec, s: float) -> Vec:
    return (a[0] * s, a[1] * s, a[2] * s)


def vdot(a: Vec, b: Vec) -> float:
    return a[0] * b[0] + a[1] * b[1] + a[2] * b[2]


def vcross(a: Vec, b: Vec) -> Vec:
    return (
        a[1] * b[2] - a[2] * b[1],
        a[2] * b[0] - a[0] * b[2],
        a[0] * b[1] - a[1] * b[0],
    )


def vlen(a: Vec) -> float:
    return math.sqrt(vdot(a, a))


def vnorm(a: Vec) -> Vec:
    n = vlen(a)
    if n == 0:
        return (0.0, 0.0, 0.0)
    return (a[0] / n, a[1] / n, a[2] / n)


def ident() -> Mat:
    return [
        [1.0, 0.0, 0.0, 0.0],
        [0.0, 1.0, 0.0, 0.0],
        [0.0, 0.0, 1.0, 0.0],
        [0.0, 0.0, 0.0, 1.0],
    ]


def matmul(a: Mat, b: Mat) -> Mat:
    out = [[0.0] * 4 for _ in range(4)]
    for i in range(4):
        for j in range(4):
            out[i][j] = sum(a[i][k] * b[k][j] for k in range(4))
    return out


def apply_mat(m: Mat, v: Vec) -> Vec:
    x, y, z = v
    w = 1.0
    out = [
        m[0][0] * x + m[0][1] * y + m[0][2] * z + m[0][3] * w,
        m[1][0] * x + m[1][1] * y + m[1][2] * z + m[1][3] * w,
        m[2][0] * x + m[2][1] * y + m[2][2] * z + m[2][3] * w,
        m[3][0] * x + m[3][1] * y + m[3][2] * z + m[3][3] * w,
    ]
    if out[3] and out[3] != 1.0:
        return (out[0] / out[3], out[1] / out[3], out[2] / out[3])
    return (out[0], out[1], out[2])


def scale_mat(s: Vec) -> Mat:
    return [
        [s[0], 0.0, 0.0, 0.0],
        [0.0, s[1], 0.0, 0.0],
        [0.0, 0.0, s[2], 0.0],
        [0.0, 0.0, 0.0, 1.0],
    ]


def translate_mat(t: Vec) -> Mat:
    m = ident()
    m[0][3], m[1][3], m[2][3] = t
    return m


def rotate_axis_angle_mat(axis: Vec, degrees: float) -> Mat:
    ax = vnorm(axis)
    x, y, z = ax
    a = math.radians(degrees)
    c = math.cos(a)
    s = math.sin(a)
    t = 1.0 - c
    return [
        [t*x*x + c,   t*x*y - s*z, t*x*z + s*y, 0.0],
        [t*x*y + s*z, t*y*y + c,   t*y*z - s*x, 0.0],
        [t*x*z - s*y, t*y*z + s*x, t*z*z + c,   0.0],
        [0.0, 0.0, 0.0, 1.0],
    ]


# -----------------------------
# Tokenizer
# -----------------------------

TOKEN_RE = re.compile(
    r'''(
        \#declare|\#local|\#macro|\#end|\#for|\#while|\#if|\#else|\#switch|\#case|\#break|
        [A-Za-z_][A-Za-z0-9_]* |
        \d+\.\d*([eE][+-]?\d+)? | \.\d+([eE][+-]?\d+)? | \d+([eE][+-]?\d+)? |
        <=|>=|==|!=|\|\||&&|\+|-|\*|/|<|>|=|\(|\)|\{|\}|\[|\]|,|; 
    )''',
    re.VERBOSE,
)


def strip_comments(text: str) -> str:
    return re.sub(r'//.*', '', text)


class TokenStream:
    def __init__(self, text: str):
        text = strip_comments(text)
        self.tokens = [m.group(1) for m in TOKEN_RE.finditer(text)]
        self.i = 0

    def peek(self, off: int = 0) -> Optional[str]:
        j = self.i + off
        return self.tokens[j] if j < len(self.tokens) else None

    def pop(self, expected: Optional[str] = None) -> str:
        tok = self.peek()
        if tok is None:
            raise ValueError('Unexpected EOF')
        if expected is not None and tok != expected:
            raise ValueError(f'Expected {expected!r}, got {tok!r}')
        self.i += 1
        return tok

    def match(self, *choices: str) -> Optional[str]:
        tok = self.peek()
        if tok in choices:
            self.i += 1
            return tok
        return None


# -----------------------------
# AST nodes
# -----------------------------

@dataclass
class Expr:
    kind: str
    value: Any = None
    args: Any = None


@dataclass
class Node:
    kind: str
    data: Any = None


# -----------------------------
# Parser
# -----------------------------

class Parser:
    def __init__(self, text: str):
        self.ts = TokenStream(text)

    def parse(self) -> List[Node]:
        out: List[Node] = []
        while self.ts.peek() is not None:
            out.append(self.parse_stmt())
        return out

    def parse_stmt(self) -> Node:
        tok = self.ts.peek()
        if tok in ('#declare', '#local'):
            kind = self.ts.pop()
            name = self.ts.pop()
            self.ts.pop('=')
            expr = self.parse_expr()
            self.ts.match(';')
            return Node('assign', (name, expr))
        if tok == '#macro':
            return self.parse_macro()
        if tok == '#for':
            return self.parse_for()
        if tok == '#while':
            return self.parse_while()
        if tok == '#if':
            return self.parse_if()
        if tok == 'union':
            return self.parse_union_like('union')
        if tok in ('triangle', 'polygon', 'sphere', 'cylinder', 'pigment', 'finish', 'photons', 'background', 'camera', 'global_settings', 'light_source'):
            return self.parse_object_or_block()
        if tok in ('rotate', 'scale', 'translate'):
            op = self.ts.pop()
            expr = self.parse_expr()
            return Node('transform', (op, expr))
        if re.match(r'[A-Za-z_]', tok or ''):
            # Macro call or bare modifier-like statement.
            name = self.ts.pop()
            if self.ts.match('('):
                args: List[Expr] = []
                if self.ts.peek() != ')':
                    while True:
                        args.append(self.parse_expr())
                        if not self.ts.match(','):
                            break
                self.ts.pop(')')
                return Node('call', (name, args))
            # Unrecognized bare identifier statement; try to skip one block/expression.
            return Node('noop', name)
        raise ValueError(f'Cannot parse statement starting with {tok!r}')

    def parse_macro(self) -> Node:
        self.ts.pop('#macro')
        name = self.ts.pop()
        self.ts.pop('(')
        params: List[str] = []
        if self.ts.peek() != ')':
            while True:
                params.append(self.ts.pop())
                if not self.ts.match(','):
                    break
        self.ts.pop(')')
        # POV macros can be expression-bodied or statement-bodied.
        statement_starters = {
            '#declare', '#local', '#macro', '#end', '#for', '#while', '#if',
            'union', 'triangle', 'polygon', 'sphere', 'cylinder', 'pigment',
            'finish', 'photons', 'background', 'camera', 'global_settings',
            'light_source', 'rotate', 'scale', 'translate'
        }
        if self.ts.peek() not in statement_starters:
            expr = self.parse_expr()
            self.ts.match(';')
            self.ts.pop('#end')
            return Node('macro_expr', (name, params, expr))
        body: List[Node] = []
        while self.ts.peek() != '#end':
            body.append(self.parse_stmt())
        self.ts.pop('#end')
        return Node('macro', (name, params, body))

    def parse_for(self) -> Node:
        self.ts.pop('#for')
        self.ts.pop('(')
        var = self.ts.pop()
        self.ts.pop(',')
        start = self.parse_expr()
        self.ts.pop(',')
        end = self.parse_expr()
        self.ts.pop(',')
        step = self.parse_expr()
        self.ts.pop(')')
        body: List[Node] = []
        while self.ts.peek() != '#end':
            body.append(self.parse_stmt())
        self.ts.pop('#end')
        return Node('for', (var, start, end, step, body))

    def parse_while(self) -> Node:
        self.ts.pop('#while')
        self.ts.pop('(')
        cond = self.parse_expr()
        self.ts.pop(')')
        body: List[Node] = []
        depth = 1
        # parse nested statements conservatively until matching #end
        while depth > 0:
            if self.ts.peek() is None:
                raise ValueError('Unterminated #while')
            if self.ts.peek() == '#while':
                body.append(self.parse_while())
            elif self.ts.peek() == '#if':
                body.append(self.parse_if())
            elif self.ts.peek() == '#for':
                body.append(self.parse_for())
            elif self.ts.peek() == '#macro':
                body.append(self.parse_macro())
            elif self.ts.peek() == '#end':
                self.ts.pop('#end')
                depth -= 1
                if depth == 0:
                    break
            else:
                body.append(self.parse_stmt())
        return Node('while', (cond, body))

    def parse_if(self) -> Node:
        self.ts.pop('#if')
        self.ts.pop('(')
        cond = self.parse_expr()
        self.ts.pop(')')
        then_body: List[Node] = []
        else_body: List[Node] = []
        current = then_body
        while True:
            tok = self.ts.peek()
            if tok is None:
                raise ValueError('Unterminated #if')
            if tok == '#else':
                self.ts.pop('#else')
                current = else_body
                continue
            if tok == '#end':
                self.ts.pop('#end')
                break
            current.append(self.parse_stmt())
        return Node('if', (cond, then_body, else_body))

    def parse_union_like(self, name: str) -> Node:
        self.ts.pop(name)
        self.ts.pop('{')
        body: List[Node] = []
        while self.ts.peek() != '}':
            body.append(self.parse_stmt())
        self.ts.pop('}')
        return Node('block', (name, body))

    def parse_object_or_block(self) -> Node:
        name = self.ts.pop()
        self.ts.pop('{')
        if name == 'triangle':
            a = self.parse_expr(); self.ts.pop(',')
            b = self.parse_expr(); self.ts.pop(',')
            c = self.parse_expr()
            extras = self.parse_object_extras_until_brace_close()
            return Node('triangle', (a, b, c, extras))
        if name == 'polygon':
            count = self.parse_expr()
            pts: List[Expr] = []
            while self.ts.peek() != '}':
                if self.ts.match(','):
                    continue
                # If we hit known modifiers, switch to extras parsing
                if self.ts.peek() in ('rotate', 'scale', 'translate', 'pigment', 'finish', 'photons'):
                    break
                pts.append(self.parse_expr())
            extras = self.parse_object_extras_until_brace_close()
            return Node('polygon', (count, pts, extras))
        if name in ('sphere', 'cylinder', 'pigment', 'finish', 'background', 'camera', 'global_settings', 'light_source', 'photons'):
            self.skip_brace_content()
            return Node('ignored', name)
        # generic block
        body: List[Node] = []
        while self.ts.peek() != '}':
            body.append(self.parse_stmt())
        self.ts.pop('}')
        return Node('block', (name, body))

    def parse_object_extras_until_brace_close(self) -> List[Node]:
        extras: List[Node] = []
        while self.ts.peek() != '}':
            tok = self.ts.peek()
            if tok in ('rotate', 'scale', 'translate'):
                op = self.ts.pop()
                extras.append(Node('transform', (op, self.parse_expr())))
            elif tok in ('pigment', 'finish', 'photons'):
                extras.append(self.parse_object_or_block())
            else:
                # Consume unrecognized token conservatively.
                self.ts.pop()
        self.ts.pop('}')
        return extras

    def skip_brace_content(self) -> None:
        depth = 1
        while depth > 0:
            tok = self.ts.pop()
            if tok == '{':
                depth += 1
            elif tok == '}':
                depth -= 1

    # Expression parser
    def parse_expr(self) -> Expr:
        return self.parse_cmp()

    def parse_cmp(self) -> Expr:
        expr = self.parse_add()
        while self.ts.peek() in ('<', '>', '<=', '>=', '==', '!='):
            op = self.ts.pop()
            rhs = self.parse_add()
            expr = Expr('binop', op, (expr, rhs))
        return expr

    def parse_add(self) -> Expr:
        expr = self.parse_mul()
        while self.ts.peek() in ('+', '-'):
            op = self.ts.pop()
            rhs = self.parse_mul()
            expr = Expr('binop', op, (expr, rhs))
        return expr

    def parse_mul(self) -> Expr:
        expr = self.parse_unary()
        while self.ts.peek() in ('*', '/'):
            op = self.ts.pop()
            rhs = self.parse_unary()
            expr = Expr('binop', op, (expr, rhs))
        return expr

    def parse_unary(self) -> Expr:
        if self.ts.peek() in ('+', '-'):
            op = self.ts.pop()
            return Expr('unary', op, self.parse_unary())
        return self.parse_primary()

    def parse_primary(self) -> Expr:
        tok = self.ts.peek()
        if tok is None:
            raise ValueError('Unexpected EOF in expression')
        if tok == '(':
            self.ts.pop('(')
            expr = self.parse_expr()
            self.ts.pop(')')
            return expr
        if tok == '<':
            self.ts.pop('<')
            a = self.parse_add(); self.ts.pop(',')
            b = self.parse_add(); self.ts.pop(',')
            c = self.parse_add(); self.ts.pop('>')
            return Expr('vector', None, (a, b, c))
        if re.fullmatch(r'(?:\d+\.\d*|\.\d+|\d+)(?:[eE][+-]?\d+)?', tok):
            self.ts.pop()
            return Expr('num', float(tok))
        if re.match(r'[A-Za-z_]', tok):
            name = self.ts.pop()
            if self.ts.match('('):
                args: List[Expr] = []
                if self.ts.peek() != ')':
                    while True:
                        args.append(self.parse_expr())
                        if not self.ts.match(','):
                            break
                self.ts.pop(')')
                return Expr('call', name, args)
            return Expr('name', name)
        raise ValueError(f'Bad expression token {tok!r}')


# -----------------------------
# Evaluator / interpreter
# -----------------------------

@dataclass
class MacroDef:
    params: List[str]
    body: Optional[List[Node]] = None
    expr: Optional[Expr] = None


class Env:
    def __init__(self, parent: Optional['Env'] = None):
        self.parent = parent
        self.vars: Dict[str, Any] = {}
        self.macros: Dict[str, MacroDef] = {}

    def get(self, name: str) -> Any:
        if name in self.vars:
            return self.vars[name]
        if self.parent is not None:
            return self.parent.get(name)
        raise KeyError(name)

    def set(self, name: str, value: Any) -> None:
        self.vars[name] = value

    def get_macro(self, name: str) -> MacroDef:
        if name in self.macros:
            return self.macros[name]
        if self.parent is not None:
            return self.parent.get_macro(name)
        raise KeyError(name)

    def set_macro(self, name: str, macro: MacroDef) -> None:
        self.macros[name] = macro


@dataclass
class Face:
    verts: List[Vec]


class Interpreter:
    def __init__(self, ast: List[Node], clock: float = 0.0):
        self.ast = ast
        self.clock = clock
        self.faces: List[Face] = []
        self.global_env = Env()
        self._install_builtins()

    def _install_builtins(self) -> None:
        e = self.global_env
        e.set('pi', math.pi)
        e.set('x', (1.0, 0.0, 0.0))
        e.set('y', (0.0, 1.0, 0.0))
        e.set('z', (0.0, 0.0, 1.0))
        e.set('clock', self.clock)
        e.set('rotation', 0.123456789)  # deterministic dummy seed object/value
        # expression macros / functions used in these files
        e.set_macro('ReflectPointThroughPlane', MacroDef(
            params=['D', 'A', 'B', 'C'],
            expr=Parser('D + vcross(A - B, A - C) * 2 * vdot(vcross(A - B, A - C), A-D) / vdot(vcross(A - B, A - C), vcross(A - B, A - C))').parse_expr()
        ))

    def eval_expr(self, expr: Expr, env: Env) -> Any:
        k = expr.kind
        if k == 'num':
            return expr.value
        if k == 'name':
            return env.get(expr.value)
        if k == 'vector':
            a, b, c = expr.args
            return (float(self.eval_expr(a, env)), float(self.eval_expr(b, env)), float(self.eval_expr(c, env)))
        if k == 'unary':
            v = self.eval_expr(expr.args, env)
            if expr.value == '+':
                return v
            if expr.value == '-':
                if isinstance(v, tuple):
                    return (-v[0], -v[1], -v[2])
                return -v
            raise ValueError(expr.value)
        if k == 'binop':
            op = expr.value
            a = self.eval_expr(expr.args[0], env)
            b = self.eval_expr(expr.args[1], env)
            return self.apply_binop(op, a, b)
        if k == 'call':
            name = expr.value
            args = [self.eval_expr(a, env) for a in expr.args]
            if name == 'sqrt':
                return math.sqrt(args[0])
            if name == 'sin':
                return math.sin(args[0])
            if name == 'cos':
                return math.cos(args[0])
            if name == 'acos':
                return math.acos(args[0])
            if name == 'vdot':
                return vdot(args[0], args[1])
            if name == 'vcross':
                return vcross(args[0], args[1])
            if name == 'rand':
                # deterministic placeholder; enough to realize fixed rotations
                seed = float(args[0]) if not isinstance(args[0], tuple) else sum(args[0])
                x = math.sin(seed * 12.9898 + 78.233) * 43758.5453
                return x - math.floor(x)
            macro = env.get_macro(name)
            if macro.expr is not None:
                child = Env(env)
                for p, a in zip(macro.params, args):
                    child.set(p, a)
                return self.eval_expr(macro.expr, child)
            raise ValueError(f'Macro {name} cannot be used in expression context')
        raise ValueError(f'Unknown expression kind {k}')

    def apply_binop(self, op: str, a: Any, b: Any) -> Any:
        if op in ('<', '>', '<=', '>=', '==', '!='):
            return float(eval(f'a {op} b'))
        if op == '+':
            if isinstance(a, tuple) and isinstance(b, tuple):
                return vadd(a, b)
            if isinstance(a, tuple):
                return (a[0] + b, a[1] + b, a[2] + b)
            if isinstance(b, tuple):
                return (a + b[0], a + b[1], a + b[2])
            return a + b
        if op == '-':
            if isinstance(a, tuple) and isinstance(b, tuple):
                return vsub(a, b)
            if isinstance(a, tuple):
                return (a[0] - b, a[1] - b, a[2] - b)
            if isinstance(b, tuple):
                return (a - b[0], a - b[1], a - b[2])
            return a - b
        if op == '*':
            if isinstance(a, tuple) and isinstance(b, tuple):
                return (a[0] * b[0], a[1] * b[1], a[2] * b[2])
            if isinstance(a, tuple):
                return (a[0] * b, a[1] * b, a[2] * b)
            if isinstance(b, tuple):
                return (a * b[0], a * b[1], a * b[2])
            return a * b
        if op == '/':
            if isinstance(a, tuple) and isinstance(b, tuple):
                return (a[0] / b[0], a[1] / b[1], a[2] / b[2])
            if isinstance(a, tuple):
                return (a[0] / b, a[1] / b, a[2] / b)
            if isinstance(b, tuple):
                return (a / b[0], a / b[1], a / b[2])
            return a / b
        raise ValueError(op)

    def run(self) -> List[Face]:
        self.exec_nodes(self.ast, self.global_env, ident())
        return self.faces

    def exec_nodes(self, nodes: List[Node], env: Env, current_mat: Mat) -> None:
        for node in nodes:
            self.exec_node(node, env, current_mat)

    def exec_node(self, node: Node, env: Env, current_mat: Mat) -> None:
        kind = node.kind
        if kind == 'assign':
            name, expr = node.data
            env.set(name, self.eval_expr(expr, env))
            return
        if kind == 'macro':
            name, params, body = node.data
            env.set_macro(name, MacroDef(params=params, body=body))
            return
        if kind == 'macro_expr':
            name, params, expr = node.data
            env.set_macro(name, MacroDef(params=params, expr=expr))
            return
        if kind == 'for':
            var, start_e, end_e, step_e, body = node.data
            start = self.eval_expr(start_e, env)
            end = self.eval_expr(end_e, env)
            step = self.eval_expr(step_e, env)
            child = Env(env)
            i = start
            eps = 1e-9
            cmp = (lambda a, b: a <= b + eps) if step >= 0 else (lambda a, b: a >= b - eps)
            while cmp(i, end):
                child.set(var, i)
                self.exec_nodes(body, child, current_mat)
                i += step
            return
        if kind == 'while':
            cond, body = node.data
            child = Env(env)
            guard = 0
            while self.eval_expr(cond, child):
                self.exec_nodes(body, child, current_mat)
                guard += 1
                if guard > 100000:
                    raise RuntimeError('while loop guard triggered')
            return
        if kind == 'if':
            cond, then_body, else_body = node.data
            body = then_body if self.eval_expr(cond, env) else else_body
            self.exec_nodes(body, Env(env), current_mat)
            return
        if kind == 'call':
            name, args = node.data
            macro = env.get_macro(name)
            if macro.body is None:
                return
            child = Env(env)
            for p, a in zip(macro.params, args):
                child.set(p, self.eval_expr(a, env))
            self.exec_nodes(macro.body, child, current_mat)
            return
        if kind == 'block':
            _name, body = node.data
            self.exec_block(body, env, current_mat)
            return
        if kind == 'triangle':
            a, b, c, extras = node.data
            m = self.combine_transforms(current_mat, extras, env)
            verts = [apply_mat(m, self.eval_expr(a, env)), apply_mat(m, self.eval_expr(b, env)), apply_mat(m, self.eval_expr(c, env))]
            self.faces.append(Face(verts))
            return
        if kind == 'polygon':
            count_expr, pts_expr, extras = node.data
            _count = int(round(self.eval_expr(count_expr, env)))
            pts = [self.eval_expr(p, env) for p in pts_expr]
            if len(pts) >= 2 and self.close_enough(pts[0], pts[-1]):
                pts = pts[:-1]
            m = self.combine_transforms(current_mat, extras, env)
            pts = [apply_mat(m, p) for p in pts]
            for tri in triangulate_polygon_3d(pts):
                self.faces.append(Face(list(tri)))
            return
        # ignore all else

    def _flatten_block_items(self, items: List[Node], env: Env) -> List[Node]:
        out: List[Node] = []
        for node in items:
            if node.kind == 'call':
                name, args = node.data
                macro = env.get_macro(name)
                if macro.body is None:
                    out.append(node)
                    continue
                child = Env(env)
                for p, a in zip(macro.params, args):
                    child.set(p, self.eval_expr(a, env))
                out.extend(self._flatten_block_items(macro.body, child))
            else:
                out.append(node)
        return out

    def exec_block(self, body: List[Node], env: Env, current_mat: Mat) -> None:
        flat_body = self._flatten_block_items(body, env)
        block_transforms: List[Tuple[str, Any]] = []
        deferred_faces: List[Node] = []
        for node in flat_body:
            if node.kind == 'transform':
                block_transforms.append(node.data)
            elif node.kind in ('triangle', 'polygon', 'block'):
                deferred_faces.append(node)
            elif node.kind == 'call':
                deferred_faces.append(node)
            else:
                self.exec_node(node, env, current_mat)
        m = current_mat
        for op, expr in block_transforms:
            m = matmul(self.transform_matrix(op, self.eval_expr(expr, env)), m)
        for node in deferred_faces:
            self.exec_node(node, env, m)

    def transform_matrix(self, op: str, value: Any) -> Mat:
        if op == 'scale':
            if isinstance(value, tuple):
                return scale_mat(value)
            return scale_mat((value, value, value))
        if op == 'translate':
            if isinstance(value, tuple):
                return translate_mat(value)
            return translate_mat((value, value, value))
        if op == 'rotate':
            if isinstance(value, tuple):
                rx = rotate_axis_angle_mat((1.0, 0.0, 0.0), value[0])
                ry = rotate_axis_angle_mat((0.0, 1.0, 0.0), value[1])
                rz = rotate_axis_angle_mat((0.0, 0.0, 1.0), value[2])
                return matmul(rz, matmul(ry, rx))
            raise ValueError('rotate expects vector in this converter')
        raise ValueError(op)

    def combine_transforms(self, current_mat: Mat, extras: List[Node], env: Env) -> Mat:
        m = current_mat
        for n in extras:
            if n.kind == 'transform':
                op, expr = n.data
                m = matmul(self.transform_matrix(op, self.eval_expr(expr, env)), m)
        return m

    @staticmethod
    def close_enough(a: Vec, b: Vec, eps: float = 1e-9) -> bool:
        return abs(a[0]-b[0]) < eps and abs(a[1]-b[1]) < eps and abs(a[2]-b[2]) < eps


# -----------------------------
# Polygon triangulation
# -----------------------------

def triangulate_polygon_3d(pts: Sequence[Vec]) -> List[Tuple[Vec, Vec, Vec]]:
    pts = list(pts)
    if len(pts) >= 2 and close2_3d(pts[0], pts[-1]):
        pts = pts[:-1]
    if len(pts) < 3:
        return []
    if len(pts) == 3:
        return [(pts[0], pts[1], pts[2])]

    origin, u, v = best_fit_plane_basis(pts)
    poly2 = [project_to_plane(p, origin, u, v) for p in pts]

    if polygon_has_self_intersections(poly2):
        tris2 = triangulate_self_intersecting_polygon_2d(poly2)
        return [(
            lift_from_plane(a, origin, u, v),
            lift_from_plane(b, origin, u, v),
            lift_from_plane(c, origin, u, v),
        ) for (a, b, c) in tris2]

    tris_idx = ear_clip(poly2)
    if not tris_idx:
        tris_idx = [(0, i, i + 1) for i in range(1, len(pts) - 1)]
    return [(pts[i], pts[j], pts[k]) for (i, j, k) in tris_idx]


def close2_3d(a: Vec, b: Vec, eps: float = 1e-9) -> bool:
    return abs(a[0]-b[0]) <= eps and abs(a[1]-b[1]) <= eps and abs(a[2]-b[2]) <= eps


def close2(a: Tuple[float, float], b: Tuple[float, float], eps: float = 1e-9) -> bool:
    return abs(a[0]-b[0]) <= eps and abs(a[1]-b[1]) <= eps


def best_fit_plane_basis(pts: Sequence[Vec]) -> Tuple[Vec, Vec, Vec]:
    origin = pts[0]
    n = polygon_normal(pts)
    if vlen(n) < 1e-12:
        a = vsub(pts[1], pts[0])
        b = vsub(pts[2], pts[0])
        n = vnorm(vcross(a, b))
    if vlen(n) < 1e-12:
        n = (0.0, 0.0, 1.0)
    ref = (1.0, 0.0, 0.0) if abs(n[0]) < 0.9 else (0.0, 1.0, 0.0)
    u = vnorm(vcross(ref, n))
    if vlen(u) < 1e-12:
        ref = (0.0, 0.0, 1.0)
        u = vnorm(vcross(ref, n))
    v = vnorm(vcross(n, u))
    return origin, u, v


def project_to_plane(p: Vec, origin: Vec, u: Vec, v: Vec) -> Tuple[float, float]:
    d = vsub(p, origin)
    return (vdot(d, u), vdot(d, v))


def lift_from_plane(p: Tuple[float, float], origin: Vec, u: Vec, v: Vec) -> Vec:
    return vadd(origin, vadd(vmul(u, p[0]), vmul(v, p[1])))


def polygon_normal(pts: Sequence[Vec]) -> Vec:
    nx = ny = nz = 0.0
    for i in range(len(pts)):
        x1, y1, z1 = pts[i]
        x2, y2, z2 = pts[(i + 1) % len(pts)]
        nx += (y1 - y2) * (z1 + z2)
        ny += (z1 - z2) * (x1 + x2)
        nz += (x1 - x2) * (y1 + y2)
    return vnorm((nx, ny, nz))


def signed_area(poly: Sequence[Tuple[float, float]]) -> float:
    a = 0.0
    for i in range(len(poly)):
        x1, y1 = poly[i]
        x2, y2 = poly[(i + 1) % len(poly)]
        a += x1 * y2 - x2 * y1
    return 0.5 * a


def point_in_tri(p, a, b, c) -> bool:
    def s(p1, p2, p3):
        return (p1[0] - p3[0]) * (p2[1] - p3[1]) - (p2[0] - p3[0]) * (p1[1] - p3[1])
    d1 = s(p, a, b)
    d2 = s(p, b, c)
    d3 = s(p, c, a)
    has_neg = (d1 < -1e-12) or (d2 < -1e-12) or (d3 < -1e-12)
    has_pos = (d1 > 1e-12) or (d2 > 1e-12) or (d3 > 1e-12)
    return not (has_neg and has_pos)


def ear_clip(poly: Sequence[Tuple[float, float]]) -> List[Tuple[int, int, int]]:
    n = len(poly)
    if n < 3:
        return []
    idx = list(range(n))
    tris: List[Tuple[int, int, int]] = []
    ccw = signed_area(poly) > 0
    guard = 0
    while len(idx) > 3 and guard < 10000:
        ear_found = False
        m = len(idx)
        for i in range(m):
            i0, i1, i2 = idx[(i - 1) % m], idx[i], idx[(i + 1) % m]
            a, b, c = poly[i0], poly[i1], poly[i2]
            cross = (b[0] - a[0]) * (c[1] - a[1]) - (b[1] - a[1]) * (c[0] - a[0])
            if ccw and cross <= 1e-12:
                continue
            if (not ccw) and cross >= -1e-12:
                continue
            if any(point_in_tri(poly[j], a, b, c) for j in idx if j not in (i0, i1, i2)):
                continue
            tris.append((i0, i1, i2))
            del idx[i]
            ear_found = True
            break
        if not ear_found:
            return []
        guard += 1
    if len(idx) == 3:
        tris.append((idx[0], idx[1], idx[2]))
    return tris


def orient2(a, b, c) -> float:
    return (b[0] - a[0]) * (c[1] - a[1]) - (b[1] - a[1]) * (c[0] - a[0])


def on_segment(a, b, p, eps: float = 1e-9) -> bool:
    return (min(a[0], b[0]) - eps <= p[0] <= max(a[0], b[0]) + eps and
            min(a[1], b[1]) - eps <= p[1] <= max(a[1], b[1]) + eps and
            abs(orient2(a, b, p)) <= eps)


def segment_intersection_params(a, b, c, d, eps: float = 1e-9):
    bax = b[0] - a[0]
    bay = b[1] - a[1]
    dcx = d[0] - c[0]
    dcy = d[1] - c[1]
    den = bax * dcy - bay * dcx
    cax = c[0] - a[0]
    cay = c[1] - a[1]
    if abs(den) <= eps:
        for pt, t in ((a, 0.0), (b, 1.0)):
            if on_segment(c, d, pt, eps):
                u = param_on_segment(c, d, pt)
                return [(t, u, pt)]
        for pt, u in ((c, 0.0), (d, 1.0)):
            if on_segment(a, b, pt, eps):
                t = param_on_segment(a, b, pt)
                return [(t, u, pt)]
        return []
    t = (cax * dcy - cay * dcx) / den
    u = (cax * bay - cay * bax) / den
    if -eps <= t <= 1 + eps and -eps <= u <= 1 + eps:
        p = (a[0] + t * bax, a[1] + t * bay)
        return [(t, u, p)]
    return []


def param_on_segment(a, b, p) -> float:
    dx = b[0] - a[0]
    dy = b[1] - a[1]
    if abs(dx) >= abs(dy):
        return 0.0 if abs(dx) < 1e-12 else (p[0] - a[0]) / dx
    return 0.0 if abs(dy) < 1e-12 else (p[1] - a[1]) / dy


def polygon_has_self_intersections(poly: Sequence[Tuple[float, float]]) -> bool:
    n = len(poly)
    if n < 4:
        return False
    for i in range(n):
        a = poly[i]
        b = poly[(i + 1) % n]
        for j in range(i + 1, n):
            if j == i or (j + 1) % n == i or (i + 1) % n == j:
                continue
            if i == 0 and j == n - 1:
                continue
            c = poly[j]
            d = poly[(j + 1) % n]
            hits = segment_intersection_params(a, b, c, d)
            for t, u, p in hits:
                if 1e-9 < t < 1 - 1e-9 and 1e-9 < u < 1 - 1e-9:
                    return True
        
    return False


def canonical_cycle(cyc: Sequence[int]) -> Tuple[int, ...]:
    cyc = list(cyc)
    if cyc and cyc[0] == cyc[-1]:
        cyc = cyc[:-1]
    if not cyc:
        return tuple()
    rots = []
    n = len(cyc)
    for base in (cyc, list(reversed(cyc))):
        m = min(range(n), key=lambda i: base[i])
        rots.append(tuple(base[m:] + base[:m]))
    return min(rots)


def winding_number(poly: Sequence[Tuple[float, float]], p: Tuple[float, float]) -> int:
    wn = 0
    n = len(poly)
    for i in range(n):
        a = poly[i]
        b = poly[(i + 1) % n]
        if on_segment(a, b, p, 1e-9):
            return 1
        if a[1] <= p[1]:
            if b[1] > p[1] and orient2(a, b, p) > 1e-12:
                wn += 1
        else:
            if b[1] <= p[1] and orient2(a, b, p) < -1e-12:
                wn -= 1
    return wn


def triangulate_self_intersecting_polygon_2d(poly: Sequence[Tuple[float, float]]) -> List[Tuple[Tuple[float, float], Tuple[float, float], Tuple[float, float]]]:
    n = len(poly)
    splits: List[List[Tuple[float, Tuple[float, float]]]] = [[(0.0, poly[i]), (1.0, poly[(i + 1) % n])] for i in range(n)]
    for i in range(n):
        a = poly[i]
        b = poly[(i + 1) % n]
        for j in range(i + 1, n):
            if j == i or (j + 1) % n == i or (i + 1) % n == j:
                continue
            if i == 0 and j == n - 1:
                continue
            c = poly[j]
            d = poly[(j + 1) % n]
            for t, u, p in segment_intersection_params(a, b, c, d):
                if -1e-9 <= t <= 1 + 1e-9 and -1e-9 <= u <= 1 + 1e-9:
                    splits[i].append((max(0.0, min(1.0, t)), p))
                    splits[j].append((max(0.0, min(1.0, u)), p))

    nodes: List[Tuple[float, float]] = []
    def get_node(pt):
        for idx, q in enumerate(nodes):
            if close2(pt, q, 1e-8):
                return idx
        nodes.append(pt)
        return len(nodes)-1

    undirected = set()
    adj: Dict[int, List[int]] = {}
    for lst in splits:
        lst.sort(key=lambda x: x[0])
        clean = []
        for t, p in lst:
            if not clean or not close2(clean[-1][1], p, 1e-8):
                clean.append((t, p))
        for k in range(len(clean)-1):
            p = clean[k][1]
            q = clean[k+1][1]
            if close2(p, q, 1e-8):
                continue
            i = get_node(p)
            j = get_node(q)
            if i == j:
                continue
            e = (min(i, j), max(i, j))
            if e not in undirected:
                undirected.add(e)
                adj.setdefault(i, []).append(j)
                adj.setdefault(j, []).append(i)

    angle_order: Dict[int, List[int]] = {}
    for i, nbrs in adj.items():
        pi = nodes[i]
        angle_order[i] = sorted(nbrs, key=lambda j: math.atan2(nodes[j][1]-pi[1], nodes[j][0]-pi[0]))

    directed = {(i, j) for i, nbrs in adj.items() for j in nbrs}
    used = set()
    cycles = []
    for start in list(directed):
        if start in used:
            continue
        face = []
        e = start
        guard = 0
        while e not in used and guard < 10000:
            used.add(e)
            a, b = e
            face.append(a)
            nbrs = angle_order[b]
            pos = nbrs.index(a)
            c = nbrs[(pos - 1) % len(nbrs)]
            e = (b, c)
            guard += 1
            if e == start:
                break
        if e == start and len(face) >= 3:
            area = signed_area([nodes[i] for i in face])
            if abs(area) > 1e-9:
                cycles.append(face)

    out = []
    seen = set()
    for cyc in cycles:
        canon = canonical_cycle(cyc)
        if canon in seen:
            continue
        seen.add(canon)
        ring = [nodes[i] for i in cyc]
        area = signed_area(ring)
        if area <= 1e-9:
            continue
        cx = sum(p[0] for p in ring) / len(ring)
        cy = sum(p[1] for p in ring) / len(ring)
        if winding_number(poly, (cx, cy)) == 0:
            continue
        idx_tris = ear_clip(ring)
        if not idx_tris:
            idx_tris = [(0, i, i+1) for i in range(1, len(ring)-1)]
        for i, j, k in idx_tris:
            out.append((ring[i], ring[j], ring[k]))
    return out
# -----------------------------
# STL writer
# -----------------------------

def triangle_normal(a: Vec, b: Vec, c: Vec) -> Vec:
    return vnorm(vcross(vsub(b, a), vsub(c, a)))


def write_ascii_stl(path: Path, faces: Sequence[Face], solid_name: str) -> None:
    with path.open('w', encoding='utf-8') as f:
        f.write(f'solid {solid_name}\n')
        for face in faces:
            if len(face.verts) != 3:
                continue
            a, b, c = face.verts
            n = triangle_normal(a, b, c)
            f.write(f'  facet normal {n[0]:.12g} {n[1]:.12g} {n[2]:.12g}\n')
            f.write('    outer loop\n')
            for v in (a, b, c):
                f.write(f'      vertex {v[0]:.12g} {v[1]:.12g} {v[2]:.12g}\n')
            f.write('    endloop\n')
            f.write('  endfacet\n')
        f.write(f'endsolid {solid_name}\n')


# -----------------------------
# Front-end
# -----------------------------

def convert_pov_to_stl(src: Path, dst: Path, clock: float = 0.0) -> Tuple[int, int]:
    text = src.read_text(encoding='utf-8')
    ast = Parser(text).parse()
    interp = Interpreter(ast, clock=clock)
    faces = interp.run()
    # discard degenerate triangles
    good: List[Face] = []
    deg = 0
    for face in faces:
        if len(face.verts) != 3:
            continue
        a, b, c = face.verts
        n = vcross(vsub(b, a), vsub(c, a))
        if vlen(n) < 1e-12:
            deg += 1
            continue
        good.append(face)
    write_ascii_stl(dst, good, src.stem)
    return len(good), deg


def main() -> None:
    ap = argparse.ArgumentParser(description='Extract POV-Ray triangle/polygon faces and write ASCII STL.')
    ap.add_argument('input', type=Path, help='Input .pov file')
    ap.add_argument('-o', '--output', type=Path, help='Output .stl file; defaults to input stem + .stl')
    ap.add_argument('--clock', type=float, default=0.0, help='POV-Ray clock value to use during evaluation (default: 0.0)')
    args = ap.parse_args()

    out = args.output if args.output else args.input.with_suffix('.stl')
    ntri, ndegen = convert_pov_to_stl(args.input, out, clock=args.clock)
    print(f'Wrote {out} with {ntri} triangles ({ndegen} degenerate discarded).')


if __name__ == '__main__':
    main()
