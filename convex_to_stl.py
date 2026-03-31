#!/usr/bin/env python3
import argparse, math, os, re, sys
from dataclasses import dataclass
from typing import Any, List, Tuple, Optional

EPS = 1e-6

class Vec3:
    __slots__ = ('x','y','z')
    def __init__(self, x=0.0, y=0.0, z=0.0):
        self.x = float(x)
        self.y = float(y)
        self.z = float(z)
    def __add__(self, other):
        o = to_vec3(other)
        return Vec3(self.x+o.x, self.y+o.y, self.z+o.z)
    __radd__ = __add__
    def __sub__(self, other):
        o = to_vec3(other)
        return Vec3(self.x-o.x, self.y-o.y, self.z-o.z)
    def __rsub__(self, other):
        o = to_vec3(other)
        return Vec3(o.x-self.x, o.y-self.y, o.z-self.z)
    def __mul__(self, other):
        if isinstance(other, Vec3):
            return Vec3(self.x*other.x, self.y*other.y, self.z*other.z)
        return Vec3(self.x*other, self.y*other, self.z*other)
    def __rmul__(self, other):
        return self.__mul__(other)
    def __truediv__(self, other):
        if isinstance(other, Vec3):
            return Vec3(self.x/other.x, self.y/other.y, self.z/other.z)
        return Vec3(self.x/other, self.y/other, self.z/other)
    def __neg__(self):
        return Vec3(-self.x,-self.y,-self.z)
    def __repr__(self):
        return f"<{self.x:.6g},{self.y:.6g},{self.z:.6g}>"


def to_vec3(v):
    if isinstance(v, Vec3):
        return v
    if isinstance(v, (tuple, list)) and len(v) == 3:
        return Vec3(*v)
    raise TypeError(f"Expected Vec3, got {type(v)}")


def vdot(a,b):
    a = to_vec3(a); b = to_vec3(b)
    return a.x*b.x + a.y*b.y + a.z*b.z

def vcross(a,b):
    a = to_vec3(a); b = to_vec3(b)
    return Vec3(a.y*b.z-a.z*b.y, a.z*b.x-a.x*b.z, a.x*b.y-a.y*b.x)

def vlength(v):
    v = to_vec3(v)
    return math.sqrt(vdot(v,v))

def vnormalize(v):
    l = vlength(v)
    if l < EPS:
        return Vec3(0,0,0)
    return v / l

def vaxis_rotate(v, axis, ang):
    axis = vnormalize(axis)
    v = to_vec3(v)
    c = math.cos(ang); s = math.sin(ang)
    return axis * vdot(axis, v) + (v - axis * vdot(axis, v)) * c + vcross(axis, v) * s

def make_array(*dims):
    dims = [int(round(d)) for d in dims]
    if not dims:
        return []
    if len(dims) == 1:
        return [None] * dims[0]
    return [make_array(*dims[1:]) for _ in range(dims[0])]

def pov_mod(a,b):
    return int(a) % int(b)

def pov_strlen(s):
    return len(s)

def pov_substr(s, start, length):
    start = int(start) - 1
    length = int(length)
    return s[start:start+length]

def pov_val(s):
    try:
        return int(s)
    except Exception:
        return float(s)

def pov_strcmp(a,b):
    return 0 if a == b else (-1 if a < b else 1)

def pov_seed(_):
    return 0

def pov_rand(_):
    return 0.5

def translate_array_syntax(expr):
    s = expr
    while True:
        new = re.sub(r'\barray\s*((?:\[\s*[^\[\]]+\s*\])+)',
                     lambda m: 'array(' + ','.join(part.strip()[1:-1].strip() for part in re.findall(r'\[\s*[^\[\]]+\s*\]', m.group(1))) + ')',
                     s)
        if new == s:
            return s
        s = new


@dataclass
class Token:
    kind: str
    value: Any = None

@dataclass
class AssignStmt:
    scope: str
    lhs: str
    rhs: str

@dataclass
class CallStmt:
    name: str
    args: List[str]

@dataclass
class IfStmt:
    cond: str
    then_body: list
    else_body: list

@dataclass
class WhileStmt:
    cond: str
    body: list

@dataclass
class ForStmt:
    var: str
    start: str
    end: str
    step: str
    body: list

@dataclass
class SwitchCase:
    kind: str
    expr: Any
    body: list

@dataclass
class SwitchStmt:
    expr: str
    cases: List[SwitchCase]

@dataclass
class BreakStmt:
    pass

class BreakSignal(Exception):
    pass

class Env:
    def __init__(self, interp, parent=None):
        self.interp = interp
        self.parent = parent
        self.locals = {}
    def root(self):
        return self if self.parent is None else self.parent.root()
    def get(self, name):
        if name in self.locals:
            return self.locals[name]
        if self.parent is not None:
            return self.parent.get(name)
        raise KeyError(name)
    def set_local(self, name, val):
        self.locals[name] = val
    def set_declared(self, name, val):
        self.root().locals[name] = val
    def get_context(self):
        ctx = {}
        chain = []
        e = self
        while e is not None:
            chain.append(e)
            e = e.parent
        for ee in reversed(chain):
            ctx.update(ee.locals)
        ctx.update(self.interp.func_context(self))
        return ctx

class Macro:
    def __init__(self, name, params, body, expr_body=None):
        self.name = name
        self.params = params
        self.body = body
        self.expr_body = expr_body

class Interpreter:
    def __init__(self, text):
        self.text = text
        self.macros = {}
        self.global_env = Env(self)
        self._parse_globals_and_macros()
        self._init_globals()
    def reset(self):
        self.global_env = Env(self)
        self._init_globals()
    def _init_globals(self):
        g = self.global_env
        src = getattr(self, 'global_source', remove_comments(remove_block_comments(self.text)))
        for m in re.finditer(r'#declare\s+([^=;]+?)\s*=\s*(.*?);', src, re.S):
            lhs, expr = m.group(1).strip(), m.group(2).strip()
            try:
                val = self.eval_expr(expr, g)
            except Exception:
                continue
            self.assign_lhs(g, lhs, val, local=False)
        for nm in ('points','tpoints','faces'):
            if nm not in g.locals:
                g.set_declared(nm, [None]*1000)
        for nm, default in [('npoints',0),('nfaces',0)]:
            if nm not in g.locals:
                g.set_declared(nm, default)
    def func_context(self, env):
        return {
            'Vec3': Vec3,
            'sqrt': math.sqrt,
            'pow': pow,
            'sin': math.sin,
            'cos': math.cos,
            'tan': math.tan,
            'acos': math.acos,
            'abs': abs,
            'min': min,
            'max': max,
            'pi': math.pi,
            'clock': 0,
            'vdot': vdot,
            'vcross': vcross,
            'vlength': vlength,
            'vnormalize': vnormalize,
            'vaxis_rotate': vaxis_rotate,
            'mod': pov_mod,
            'strlen': pov_strlen,
            'substr': pov_substr,
            'val': pov_val,
            'strcmp': pov_strcmp,
            'seed': pov_seed,
            'rand': pov_rand,
            'array': make_array,
            'drop_vtx': lambda n: self._builtin_drop_vtx(env, int(round(n))),
            'drop_halfspace': lambda normalvector, thresh: self._builtin_drop_halfspace(env, normalvector, thresh),
            'autobalance': lambda : self._builtin_autobalance(env),
            'This_shape_will_be_drawn': lambda *args: None,
            **{name: self._macro_callable(name, env) for name in self.macros.keys()},
        }
    def _builtin_drop_vtx(self, env, n):
        # Faithful POV swap-delete semantics on a fixed-size POV array.
        root = env.root().locals
        npoints = int(root['npoints']) - 1
        root['npoints'] = npoints
        points = root['points']
        if n < npoints:
            points[n] = points[npoints]
        return None

    def _builtin_drop_halfspace(self, env, normalvector, thresh):
        root = env.root().locals
        pts = root['points']
        i = 0
        while i < int(root['npoints']) - 0.5:
            if vdot(pts[i], normalvector) < thresh - 0.01:
                self._builtin_drop_vtx(env, i)
            else:
                i += 1
        return None

    def _builtin_autobalance(self, env):
        root = env.root().locals
        n = int(root['npoints'])
        if n <= 0:
            return None
        cog = Vec3(0,0,0)
        for i in range(n):
            cog += root['points'][i]
        cog = cog / n
        for i in range(n):
            root['points'][i] = root['points'][i] - cog
        return None

    def _macro_callable(self, name, env):
        def f(*args):
            return self.call_macro(name, list(args), env)
        return f
    def _parse_globals_and_macros(self):
        src = remove_comments(remove_block_comments(self.text))
        macro_spans = []
        i = 0
        while True:
            m = re.search(r'#macro\s+([A-Za-z_][A-Za-z0-9_]*)\s*\((.*?)\)', src[i:], re.S)
            if not m:
                break
            start = i + m.start()
            name = m.group(1)
            params = [p.strip() for p in m.group(2).split(',') if p.strip()]
            body_start = i + m.end()
            depth = 1
            j = body_start
            while j < len(src):
                m2 = re.search(r'#macro\b|#if\b|#ifdef\b|#ifndef\b|#while\b|#for\b|#switch\b|#end\b', src[j:])
                if not m2:
                    raise RuntimeError(f"Unterminated macro {name}")
                k = j + m2.start()
                token = m2.group(0)
                if token in ('#macro', '#if', '#ifdef', '#ifndef', '#while', '#for', '#switch'):
                    depth += 1
                    j = k + len(token)
                else:
                    depth -= 1
                    if depth == 0:
                        body = src[body_start:k].strip()
                        expr_body = None
                        body_no_comments = remove_comments(body).strip()
                        if body_no_comments.startswith('(') and body_no_comments.endswith(')') and '#'+'' not in body_no_comments:
                            expr_body = body_no_comments
                        self.macros[name] = Macro(name, params, body, expr_body)
                        macro_spans.append((start, k + 4))
                        i = k + 4
                        break
                    j = k + 4
        pieces = []
        last = 0
        for a, b in macro_spans:
            pieces.append(src[last:a])
            last = b
        pieces.append(src[last:])
        self.global_source = ''.join(pieces)
    def translate_expr(self, expr):
        s = expr.strip()
        s = replace_vectors(s)
        s = translate_array_syntax(s)
        s = re.sub(r'(?<![<>!=])=(?!=)', '==', s)
        s = s.replace('&', ' and ').replace('|', ' or ')
        return s
    def eval_expr(self, expr, env):
        s = self.translate_expr(expr)
        return eval(s, {'__builtins__': {}}, env.get_context())
    def tokenize(self, body):
        s = remove_comments(body)
        tokens = []
        i = 0
        while i < len(s):
            if s[i].isspace():
                i += 1; continue
            if s[i] == '#':
                m = re.match(r'#([A-Za-z_]+)', s[i:])
                if not m:
                    raise RuntimeError(f"Bad directive near {s[i:i+30]!r}")
                kw = m.group(1)
                i += len(m.group(0))
                if kw in ('end','else','break'):
                    tokens.append(Token(kw)); continue
                if kw in ('if','while','switch','case','range','ifdef','ifndef','for'):
                    arg, i = read_paren_expr(s, i)
                    tokens.append(Token(kw, arg.strip())); continue
                if kw == 'debug':
                    j = find_stmt_end(s, i)
                    i = j
                    if i < len(s) and s[i] == ';': i += 1
                    continue
                if kw in ('local','declare'):
                    j = find_stmt_end(s, i)
                    txt = s[i:j].strip()
                    tokens.append(Token(kw, txt))
                    i = j
                    if i < len(s) and s[i] == ';': i += 1
                    continue
                raise RuntimeError(f"Unsupported directive #{kw}")
            if re.match(r'[A-Za-z_]', s[i]):
                name_m = re.match(r'([A-Za-z_][A-Za-z0-9_]*)', s[i:])
                name = name_m.group(1)
                i += len(name)
                while i < len(s) and s[i].isspace(): i += 1
                if i < len(s) and s[i] == '(':
                    arg, i = read_paren_expr(s, i)
                    tokens.append(Token('call', (name, split_args(arg))))
                    continue
                raise RuntimeError(f"Unexpected identifier statement {name}")
            i += 1
        return tokens
    def parse_body(self, body):
        tokens = self.tokenize(body)
        stmts, pos = self._parse_stmt_list(tokens, 0, stop_kinds=set())
        if pos != len(tokens):
            raise RuntimeError("Unparsed tokens remain")
        return stmts
    def _parse_stmt_list(self, toks, pos, stop_kinds):
        out = []
        while pos < len(toks):
            tk = toks[pos]
            if tk.kind in stop_kinds:
                break
            if tk.kind in ('local','declare'):
                lhs, rhs = split_assign(tk.value)
                out.append(AssignStmt(tk.kind, lhs, rhs))
                pos += 1
            elif tk.kind == 'call':
                out.append(CallStmt(tk.value[0], tk.value[1]))
                pos += 1
            elif tk.kind == 'if':
                cond = tk.value
                pos += 1
                then_body, pos = self._parse_stmt_list(toks, pos, {'else','end'})
                else_body = []
                if pos < len(toks) and toks[pos].kind == 'else':
                    pos += 1
                    else_body, pos = self._parse_stmt_list(toks, pos, {'end'})
                if pos >= len(toks) or toks[pos].kind != 'end':
                    raise RuntimeError('if without #end')
                pos += 1
                out.append(IfStmt(cond, then_body, else_body))
            elif tk.kind == 'ifdef':
                cond = f'({tk.value}) in locals()'
                pos += 1
                then_body, pos = self._parse_stmt_list(toks, pos, {'else','end'})
                else_body = []
                if pos < len(toks) and toks[pos].kind == 'else':
                    pos += 1
                    else_body, pos = self._parse_stmt_list(toks, pos, {'end'})
                if pos >= len(toks) or toks[pos].kind != 'end':
                    raise RuntimeError('ifdef without #end')
                pos += 1
                out.append(IfStmt(f'{tk.value} is not None', then_body, else_body))
            elif tk.kind == 'ifndef':
                pos += 1
                then_body, pos = self._parse_stmt_list(toks, pos, {'else','end'})
                else_body = []
                if pos < len(toks) and toks[pos].kind == 'else':
                    pos += 1
                    else_body, pos = self._parse_stmt_list(toks, pos, {'end'})
                if pos >= len(toks) or toks[pos].kind != 'end':
                    raise RuntimeError('ifndef without #end')
                pos += 1
                out.append(IfStmt(f'not ({tk.value} is not None)', then_body, else_body))
            elif tk.kind == 'while':
                cond = tk.value
                pos += 1
                body, pos = self._parse_stmt_list(toks, pos, {'end'})
                if pos >= len(toks) or toks[pos].kind != 'end':
                    raise RuntimeError('while without #end')
                pos += 1
                out.append(WhileStmt(cond, body))
            elif tk.kind == 'for':
                parts = split_args(tk.value)
                if len(parts) not in (3,4):
                    raise RuntimeError('for expects 3 or 4 arguments')
                var = parts[0].strip()
                start = parts[1].strip()
                end = parts[2].strip()
                step = parts[3].strip() if len(parts) == 4 else '1'
                pos += 1
                body, pos = self._parse_stmt_list(toks, pos, {'end'})
                if pos >= len(toks) or toks[pos].kind != 'end':
                    raise RuntimeError('for without #end')
                pos += 1
                out.append(ForStmt(var, start, end, step, body))
            elif tk.kind == 'switch':
                expr = tk.value
                pos += 1
                cases = []
                while pos < len(toks) and toks[pos].kind != 'end':
                    if toks[pos].kind not in ('case','range','else'):
                        raise RuntimeError('switch expected case/range/else')
                    kind = toks[pos].kind
                    val = toks[pos].value if kind != 'else' else None
                    pos += 1
                    body, pos = self._parse_stmt_list(toks, pos, {'case','range','else','end'})
                    cases.append(SwitchCase(kind, val, body))
                if pos >= len(toks) or toks[pos].kind != 'end':
                    raise RuntimeError('switch without #end')
                pos += 1
                out.append(SwitchStmt(expr, cases))
            elif tk.kind == 'break':
                out.append(BreakStmt())
                pos += 1
            else:
                raise RuntimeError(f'Unhandled token kind {tk.kind}')
        return out, pos
    def exec_stmts(self, stmts, env):
        for st in stmts:
            if isinstance(st, AssignStmt):
                val = self.eval_expr(st.rhs, env)
                if st.scope == 'local':
                    self.assign_lhs(env, st.lhs, val, local=True)
                else:
                    self.assign_lhs(env, st.lhs, val, local=False)
            elif isinstance(st, CallStmt):
                args = [self.eval_expr(a, env) for a in st.args]
                self.call_macro(st.name, args, env)
            elif isinstance(st, IfStmt):
                if self.eval_expr(st.cond, env):
                    self.exec_stmts(st.then_body, env)
                else:
                    self.exec_stmts(st.else_body, env)
            elif isinstance(st, WhileStmt):
                guard = 0
                while self.eval_expr(st.cond, env):
                    self.exec_stmts(st.body, env)
                    guard += 1
                    if guard > 200000:
                        raise RuntimeError(f'Loop guard triggered in while({st.cond}) with locals={env.locals}')
            elif isinstance(st, ForStmt):
                start = self.eval_expr(st.start, env)
                end = self.eval_expr(st.end, env)
                step = self.eval_expr(st.step, env)
                if abs(step) < EPS:
                    raise RuntimeError('for step may not be zero')
                i = start
                guard = 0
                def cont(cur):
                    return cur <= end + EPS if step > 0 else cur >= end - EPS
                while cont(i):
                    env.set_local(st.var, i)
                    self.exec_stmts(st.body, env)
                    i = i + step
                    guard += 1
                    if guard > 200000:
                        raise RuntimeError(f'Loop guard triggered in for({st.var},{st.start},{st.end},{st.step}) with locals={env.locals}')
            elif isinstance(st, SwitchStmt):
                val = self.eval_expr(st.expr, env)
                matched = False
                for case in st.cases:
                    hit = False
                    if case.kind == 'case':
                        hit = (val == self.eval_expr(case.expr, env))
                    elif case.kind == 'range':
                        lo, hi = split_args(case.expr)
                        hit = self.eval_expr(lo, env) <= val <= self.eval_expr(hi, env)
                    elif case.kind == 'else':
                        hit = not matched
                    if hit or matched:
                        matched = True
                        try:
                            self.exec_stmts(case.body, env)
                        except BreakSignal:
                            break
            elif isinstance(st, BreakStmt):
                raise BreakSignal()
    def assign_lhs(self, env, lhs, val, local=False):
        lhs = lhs.strip()
        m = re.match(r'^([A-Za-z_][A-Za-z0-9_]*)(.*)$', lhs)
        if not m:
            raise RuntimeError(f'Bad lhs {lhs}')
        name, tail = m.group(1), m.group(2)
        if not tail:
            if local:
                env.set_local(name, val)
            else:
                env.set_declared(name, val)
            return
        target_env = env if local else env.root()
        if name in target_env.locals:
            obj = target_env.locals[name]
        else:
            obj = env.get(name)
        idxs = re.findall(r'\[(.*?)\]', tail)
        idx_vals = [int(round(self.eval_expr(ix, env))) for ix in idxs]
        ref = obj
        for ix in idx_vals[:-1]:
            while ix >= len(ref):
                ref.append(None)
            if ref[ix] is None:
                ref[ix] = []
            ref = ref[ix]
        ix = idx_vals[-1]
        while ix >= len(ref):
            ref.append(None)
        ref[ix] = val
        if not local:
            target_env.locals[name] = obj
    def call_macro(self, name, args, caller_env=None):
        if name == 'drop_vtx':
            return self._builtin_drop_vtx(caller_env or self.global_env, int(round(args[0])))
        if name == 'drop_halfspace':
            return self._builtin_drop_halfspace(caller_env or self.global_env, args[0], args[1])
        if name == 'autobalance':
            return self._builtin_autobalance(caller_env or self.global_env)
        if name not in self.macros:
            raise RuntimeError(f'Unknown macro {name}')
        macro = self.macros[name]
        if len(args) != len(macro.params):
            raise RuntimeError(f'{name} expects {len(macro.params)} args, got {len(args)}')
        env = Env(self, parent=caller_env or self.global_env)
        for p,a in zip(macro.params, args):
            env.set_local(p, a)
        if macro.expr_body is not None:
            return self.eval_expr(macro.expr_body, env)
        if not hasattr(macro, 'ast'):
            macro.ast = self.parse_body(macro.body)
        self.exec_stmts(macro.ast, env)
        return None
    def list_shapes(self):
        helpers = {
            'addpoint','addevenperms','addperms','addpointssgn','addevenpermssgn','addpermssgn','addpointsevensgn',
            'addevenpermsevensgn','addpermsaltsgn','addface','polygon_vtx','augment','rotateabout','rotate_vtxs','drop_vtx',
            'drop_halfspace','autobalance','showvtxs','drawit','dual','autoface','dorot','addp','addedge','addplane',
            'make_triangle','make_square','make_lune','optimise','planes','rprism_vtx','antiprism_vtx','rprism','antiprism'
        }
        out=[]
        for name, m in self.macros.items():
            if name not in helpers and not name.startswith('This_shape'):
                out.append((name,m.params))
        return sorted(out)

def remove_block_comments(s):
    return re.sub(r'/\*.*?\*/', '', s, flags=re.S)

def remove_comments(s):
    return re.sub(r'//.*', '', s)

def read_paren_expr(s, i):
    while i < len(s) and s[i].isspace(): i += 1
    if i >= len(s) or s[i] != '(':
        raise RuntimeError('Expected (')
    depth = 0
    j = i
    in_string = False
    while j < len(s):
        ch = s[j]
        if ch == '"' and (j == 0 or s[j-1] != '\\'):
            in_string = not in_string
        elif not in_string:
            if ch == '(':
                depth += 1
            elif ch == ')':
                depth -= 1
                if depth == 0:
                    return s[i+1:j], j+1
        j += 1
    raise RuntimeError('Unterminated parenthesized expression')

def find_stmt_end(s, i):
    depth = 0; angle = 0; in_string = False
    j = i
    while j < len(s):
        ch = s[j]
        if ch == '"' and (j == 0 or s[j-1] != '\\'):
            in_string = not in_string
        elif not in_string:
            if ch == '(':
                depth += 1
            elif ch == ')':
                depth -= 1
            elif ch == '<':
                angle += 1
            elif ch == '>':
                angle -= 1
            elif ch == ';' and depth == 0 and angle == 0:
                return j
            elif ch == '#' and depth == 0 and angle == 0:
                return j
        j += 1
    return j

def split_args(s):
    parts = []
    depth = angle = 0
    in_string = False
    cur = []
    for i,ch in enumerate(s):
        if ch == '"' and (i == 0 or s[i-1] != '\\'):
            in_string = not in_string
        if not in_string:
            if ch == '(':
                depth += 1
            elif ch == ')':
                depth -= 1
            elif ch == '<':
                angle += 1
            elif ch == '>':
                angle -= 1
            elif ch == ',' and depth == 0 and angle == 0:
                parts.append(''.join(cur).strip()); cur=[]; continue
        cur.append(ch)
    if ''.join(cur).strip() or s.strip()=='' and not parts:
        parts.append(''.join(cur).strip())
    return [] if len(parts)==1 and parts[0]=='' else parts

def split_assign(s):
    depth = angle = 0
    in_string = False
    for i,ch in enumerate(s):
        if ch == '"' and (i == 0 or s[i-1] != '\\'):
            in_string = not in_string
        if in_string:
            continue
        if ch == '(':
            depth += 1
        elif ch == ')':
            depth -= 1
        elif ch == '<':
            angle += 1
        elif ch == '>':
            angle -= 1
        elif ch == '=' and depth == 0 and angle == 0:
            return s[:i].strip(), s[i+1:].strip()
    raise RuntimeError(f'Not an assignment: {s}')

def replace_vectors(s):
    out=[]; i=0
    while i < len(s):
        if s[i] == '<':
            depth = 1; j = i+1; in_string = False; found = False
            while j < len(s):
                ch = s[j]
                if ch == '"' and (j == 0 or s[j-1] != "\\"):
                    in_string = not in_string
                elif not in_string:
                    if ch == '<':
                        depth += 1
                    elif ch == '>':
                        depth -= 1
                        if depth == 0:
                            found = True
                            break
                j += 1
            if not found:
                out.append('<'); i += 1; continue
            inner = s[i+1:j]
            comps = split_args(inner)
            if len(comps) == 3:
                out.append(f"Vec3({comps[0]},{comps[1]},{comps[2]})")
            else:
                out.append('<'+inner+'>')
            i = j+1
        else:
            out.append(s[i]); i += 1
    return ''.join(out)

def active_points(env):
    pts = env.root().locals['points']
    n = int(env.root().locals['npoints'])
    return [pts[i] for i in range(n)]

def active_faces(env):
    fs = env.root().locals['faces']
    n = int(env.root().locals['nfaces'])
    return [fs[i] for i in range(n)]

def scale_like_pov(interp):
    env = interp.global_env
    pts = active_points(env)
    if not pts:
        return
    b = max(vlength(p) for p in pts)
    root = env.root().locals
    for i in range(int(root['npoints'])):
        root['points'][i] = root['points'][i] / b
    for i in range(int(root['nfaces'])):
        root['faces'][i] = root['faces'][i] * b

def reconstruct_polygons(interp):
    env = interp.global_env
    pts = active_points(env)
    fs = active_faces(env)
    polys = []
    for face in fs:
        idx = [i for i,p in enumerate(pts) if vdot(face,p) > 1 - 1e-5]
        if len(idx) < 3:
            continue
        n = vnormalize(face)
        center = Vec3(0,0,0)
        for i in idx: center += pts[i]
        center = center / len(idx)
        ref = pts[idx[0]] - center
        if vlength(ref) < EPS:
            ref = Vec3(1,0,0)
            if abs(vdot(ref,n)) > 0.9: ref = Vec3(0,1,0)
        u = vnormalize(ref - n*vdot(ref,n))
        if vlength(u) < EPS:
            tmp = Vec3(1,0,0)
            if abs(vdot(tmp,n)) > 0.9: tmp = Vec3(0,1,0)
            u = vnormalize(tmp - n*vdot(tmp,n))
        v = vcross(n,u)
        ordered = sorted(idx, key=lambda i: math.atan2(vdot(pts[i]-center, v), vdot(pts[i]-center, u)))
        uniq = []
        for i in ordered:
            if not uniq or vlength(pts[i]-pts[uniq[-1]]) > 1e-6:
                uniq.append(i)
        if len(uniq) >= 3 and vlength(pts[uniq[0]]-pts[uniq[-1]]) <= 1e-6:
            uniq.pop()
        if len(uniq) >= 3:
            polys.append(uniq)
    return pts, polys

def triangulate(poly):
    return [(poly[0], poly[i], poly[i+1]) for i in range(1, len(poly)-1)]

def facet_normal(a,b,c):
    return vnormalize(vcross(b-a, c-a))

def write_ascii_stl(path, name, pts, polys):
    with open(path, 'w', encoding='ascii', newline='\n') as f:
        f.write(f'solid {name}\n')
        for poly in polys:
            for i,j,k in triangulate(poly):
                a,b,c = pts[i], pts[j], pts[k]
                n = facet_normal(a,b,c)
                f.write(f'  facet normal {n.x:.9g} {n.y:.9g} {n.z:.9g}\n')
                f.write('    outer loop\n')
                for p in (a,b,c):
                    f.write(f'      vertex {p.x:.9g} {p.y:.9g} {p.z:.9g}\n')
                f.write('    endloop\n')
                f.write('  endfacet\n')
        f.write(f'endsolid {name}\n')

def write_binary_stl(path, name, pts, polys):
    import struct
    tris = []
    for poly in polys:
        for i, j, k in triangulate(poly):
            a, b, c = pts[i], pts[j], pts[k]
            n = facet_normal(a, b, c)
            tris.append((n, a, b, c))
    header_txt = f'POV to STL: {name}'[:80]
    header = header_txt.encode('ascii', 'replace').ljust(80, b'\0')
    with open(path, 'wb') as f:
        f.write(header)
        f.write(struct.pack('<I', len(tris)))
        for n, a, b, c in tris:
            f.write(struct.pack(
                '<12fH',
                float(n.x), float(n.y), float(n.z),
                float(a.x), float(a.y), float(a.z),
                float(b.x), float(b.y), float(b.z),
                float(c.x), float(c.y), float(c.z),
                0
            ))

def parse_call_spec(spec):
    m = re.match(r'\s*([A-Za-z_][A-Za-z0-9_]*)\s*\((.*)\)\s*$', spec)
    if not m:
        raise ValueError(f'Bad call spec: {spec}')
    return m.group(1), split_args(m.group(2))

def export_shape(interp, name, arg_exprs, outdir, stl_format='binary', output_path=None):
    interp.reset()
    args = [interp.eval_expr(a, interp.global_env) for a in arg_exprs]
    interp.call_macro(name, args, interp.global_env)
    scale_like_pov(interp)
    pts, polys = reconstruct_polygons(interp)
    slug = name if not arg_exprs else name + '_' + '_'.join(re.sub(r'[^A-Za-z0-9]+','',a) or 'arg' for a in arg_exprs)
    if output_path:
        path = output_path
        outdir2 = os.path.dirname(path)
        if outdir2:
            os.makedirs(outdir2, exist_ok=True)
    else:
        os.makedirs(outdir, exist_ok=True)
        path = os.path.join(outdir, f'{slug}.stl')
    if stl_format == 'ascii':
        write_ascii_stl(path, slug, pts, polys)
    else:
        write_binary_stl(path, slug, pts, polys)
    return path, len(pts), len(polys)

def default_args_for(name, params):
    if len(params) == 0:
        return []
    if len(params) == 1:
        p = params[0]
        if p == 'augmentation':
            return ['1']
        if p == 's':
            return ['1']
        if p == 'n':
            presets = {
                'dipyramid':'5', 'bipyramid':'5', 'trapezohedron':'5', 'elongated_pyramid':'4',
                'elongated_dipyramid':'5', 'rprism':'5', 'antiprism':'5', 'polygon_vtx':'5',
                'rprism_vtx':'5', 'antiprism_vtx':'5', 'sphenocoronae':'86'
            }
            return [presets.get(name,'5')]
        if p == 'mods':
            return ['"DGGD"']
        return ['1']
    if name == 'augmented_prisms':
        return ['5','"0"']
    return None

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('povfile')
    ap.add_argument('--list', action='store_true')
    ap.add_argument('--shape', action='append', default=[])
    ap.add_argument('--args', action='append', default=[])
    ap.add_argument('--call', action='append', default=[])
    ap.add_argument('--all', action='store_true')
    ap.add_argument('--outdir', default='stl_out')
    ap.add_argument('--output', help='Explicit output STL filename for a single export job')
    ap.add_argument('--format', choices=['binary','ascii'], default='binary')
    ns = ap.parse_args()

    with open(ns.povfile, 'r', encoding='utf-8') as f:
        txt = f.read()
    interp = Interpreter(txt)

    if ns.list:
        for name, params in interp.list_shapes():
            print(f"{name}({', '.join(params)})")
        return

    jobs = []
    if ns.shape:
        arglists = ns.args or []
        if arglists and len(arglists) != len(ns.shape):
            raise SystemExit('--args must appear once per --shape when used')
        for idx,name in enumerate(ns.shape):
            args = split_args(arglists[idx]) if idx < len(arglists) else []
            jobs.append((name,args))
    for spec in ns.call:
        jobs.append(parse_call_spec(spec))
    if ns.all:
        for name, params in interp.list_shapes():
            defaults = default_args_for(name, params)
            if defaults is not None:
                jobs.append((name, defaults))
    if not jobs:
        raise SystemExit('No export job specified')

    if ns.output and len(jobs) != 1:
        raise SystemExit('--output may only be used when exactly one export job is specified')

    seen = set()
    for name,args in jobs:
        key = (name, tuple(args))
        if key in seen: continue
        seen.add(key)
        path, nv, nf = export_shape(interp, name, args, ns.outdir, ns.format, ns.output)
        print(f"Wrote {path}  ({nv} vertices, {nf} faces)")

if __name__ == '__main__':
    main()
