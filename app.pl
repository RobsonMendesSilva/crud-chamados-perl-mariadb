#!/usr/bin/perl
use Mojolicious::Lite -signatures;
use DBI;
app->secrets(['laboratorio-crud-perl']);
helper db => sub {
my $c = shift;
my $host = $ENV{DB_HOST} // '127.0.0.1';
my $name = $ENV{DB_NAME} // 'chamados_perl';
my $user = $ENV{DB_USER} // 'chamados_app';
my $pass = $ENV{DB_PASS}
    // die "Defina a variável de ambiente DB_PASS\n";
# 1. Garanta que o início seja DBI:mysql
my $dsn = "DBI:mysql:database=$name;host=$host;port=3306";

return DBI->connect(
    $dsn, $user, $pass,
    {
        RaiseError => 1,
        PrintError => 0,
        AutoCommit => 1,
        # 2. Altere aqui para usar "mysql_" em vez de "mariadb_"
        mysql_enable_utf8mb4 => 1, 
    }
);

};
get '/' => sub ($c) {
$c->redirect_to('/chamados');
};
# -------------------------
# USUÁRIOS - READ
# -------------------------
get '/usuarios' => sub ($c) {
my $dbh = $c->db;
my $rows = $dbh->selectall_arrayref(
'SELECT id, nome, email FROM usuarios ORDER BY id DESC',
{ Slice => {} }
);
$c->render(template => 'usuarios/index', usuarios => $rows);
};
# USUÁRIOS - CREATE FORM
get '/usuarios/novo' => sub ($c) {
    $c->render(
        template => 'usuarios/form',
        usuario  => undef
    );
};

# USUÁRIOS - CREATE
post '/usuarios' => sub ($c) {
my $nome = $c->param('nome');
my $email = $c->param('email');
my $dbh = $c->db;
my $sth = $dbh->prepare(
'INSERT INTO usuarios (nome, email) VALUES (?, ?)'
);
$sth->execute($nome, $email);
$c->redirect_to('/usuarios');
};
# USUÁRIOS - UPDATE FORM
get '/usuarios/:id/editar' => sub ($c) {
my $id = $c->param('id');
my $dbh = $c->db;
my $usuario = $dbh->selectrow_hashref(
'SELECT id, nome, email FROM usuarios WHERE id = ?',
undef, $id
);
return $c->reply->not_found unless $usuario;
$c->render(template => 'usuarios/form', usuario => $usuario);
};
# USUÁRIOS - UPDATE
post '/usuarios/:id' => sub ($c) {
my $id
= $c->param('id');
my $nome = $c->param('nome');
my $email = $c->param('email');
my $dbh = $c->db;
my $sth = $dbh->prepare(
'UPDATE usuarios SET nome = ?, email = ? WHERE id = ?'
);
$sth->execute($nome, $email, $id);
$c->redirect_to('/usuarios');
};
# USUÁRIOS - DELETE
post '/usuarios/:id/excluir' => sub ($c) {
my $id = $c->param('id');
my $dbh = $c->db;
my $sth = $dbh->prepare(
'DELETE FROM usuarios WHERE id = ?'
);
$sth->execute($id);
$c->redirect_to('/usuarios');
};
# -------------------------
# CHAMADOS - READ
# -------------------------
get '/chamados' => sub ($c) {
my $dbh = $c->db;
my $rows = $dbh->selectall_arrayref(
'SELECT c.id, c.titulo, c.descricao, c.status,
c.data_abertura, c.usuario_id, u.nome AS usuario
FROM chamados c
JOIN usuarios u ON u.id = c.usuario_id
ORDER BY c.id DESC',
{ Slice => {} }
);
$c->render(template => 'chamados/index', chamados => $rows);
};

# CHAMADOS - CREATE FORM
get '/chamados/novo' => sub ($c) {
    my $dbh = $c->db;

    my $usuarios = $dbh->selectall_arrayref(
        'SELECT id, nome FROM usuarios ORDER BY nome',
        { Slice => {} }
    );

    $c->render(
        template => 'chamados/form',
        usuarios => $usuarios,
        chamado => undef
    );
};

# CHAMADOS - CREATE
post '/chamados' => sub ($c) {
my $titulo
= $c->param('titulo');
my $descricao = $c->param('descricao');
my $status
= $c->param('status');
my $usuario_id = $c->param('usuario_id');
my $dbh = $c->db;
my $sth = $dbh->prepare(
'INSERT INTO chamados
(titulo, descricao, status, usuario_id)
VALUES (?, ?, ?, ?)'
);
$sth->execute($titulo, $descricao, $status, $usuario_id);
$c->redirect_to('/chamados');
};
# CHAMADOS - UPDATE FORM
get '/chamados/:id/editar' => sub ($c) {
my $id = $c->param('id');
my $dbh = $c->db;
my $chamado = $dbh->selectrow_hashref(
'SELECT id, titulo, descricao, status, usuario_id
FROM chamados WHERE id = ?',
undef, $id
);
return $c->reply->not_found unless $chamado;
my $usuarios = $dbh->selectall_arrayref(
'SELECT id, nome FROM usuarios ORDER BY nome',
{ Slice => {} }
);
$c->render(
template => 'chamados/form',
chamado => $chamado,
usuarios => $usuarios
);
};
# CHAMADOS - UPDATE
post '/chamados/:id' => sub ($c) {
my $id
= $c->param('id');
my $titulo
= $c->param('titulo');
my $descricao = $c->param('descricao');
my $status
= $c->param('status');
my $usuario_id = $c->param('usuario_id');
my $dbh = $c->db;
my $sth = $dbh->prepare(
'UPDATE chamados
SET titulo = ?, descricao = ?, status = ?, usuario_id = ?
WHERE id = ?'
);
$sth->execute($titulo, $descricao, $status, $usuario_id, $id);
$c->redirect_to('/chamados');
};
# CHAMADOS - DELETE
post '/chamados/:id/excluir' => sub ($c) {
my $id = $c->param('id');
my $dbh = $c->db;
my $sth = $dbh->prepare(
'DELETE FROM chamados WHERE id = ?'
);
$sth->execute($id);
$c->redirect_to('/chamados');
};
app->start;
__DATA__
@@ layouts/default.html.ep
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<title>CRUD de Chamados</title>
<style>
body { font-family: Arial, sans-serif; max-width: 1050px;
margin: 30px auto; padding: 0 15px; }
nav { margin-bottom: 25px; }
nav a, .btn { background: #174A7C; color: white;
padding: 8px 12px; text-decoration: none;
border-radius: 5px; margin-right: 5px; }
table { width: 100%; border-collapse: collapse; }
th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
th { background: #eef4f8; }
input, textarea, select { width: 100%; padding: 8px;
box-sizing: border-box; margin-bottom: 10px; }
button { padding: 8px 12px; cursor: pointer; }
.danger { background: #c0392b; color: white; border: 0; }
</style>
</head>
<body>
<nav>
<a href="/chamados">Chamados</a>
<a href="/chamados/novo">Novo chamado</a>
<a href="/usuarios">Usuários</a>
<a href="/usuarios/novo">Novo usuário</a>
</nav>
<%= content %>
</body>
</html>
@@ usuarios/index.html.ep
% layout 'default';
<h1>Usuários</h1>
<table>
<tr><th>ID</th><th>Nome</th><th>E-mail</th><th>Ações</th></tr>
% for my $u (@$usuarios) {
<tr>
<td><%= $u->{id} %></td>
<td><%= $u->{nome} %></td>
<td><%= $u->{email} %></td>
<td>
<a href="/usuarios/<%= $u->{id} %>/editar">Editar</a>
<form method="post"
action="/usuarios/<%= $u->{id} %>/excluir"
style="display:inline">
<button class="danger"
onclick="return confirm('Excluir usuário?')">
Excluir
</button>
</form>
</td>
</tr>
% }
</table>
@@ usuarios/form.html.ep
% layout 'default';
% my $editando = $usuario ? 1 : 0;
<h1><%= $editando ? 'Editar usuário' : 'Novo usuário' %></h1>
<form method="post"
action="<%= $editando ? '/usuarios/' . $usuario->{id} : '/usuarios' %>">
<label>Nome</label>
<input name="nome" required
value="<%= $editando ? $usuario->{nome} : '' %>">
<label>E-mail</label>
<input type="email" name="email" required
value="<%= $editando ? $usuario->{email} : '' %>">
<button type="submit">Salvar</button>
</form>
@@ chamados/index.html.ep
% layout 'default';
<h1>Chamados</h1>
<table>
<tr>
<th>ID</th><th>Título</th><th>Status</th>
<th>Usuário</th><th>Data</th><th>Ações</th>
</tr>
% for my $c (@$chamados) {
<tr>
<td><%= $c->{id} %></td>
<td><%= $c->{titulo} %></td>
<td><%= $c->{status} %></td>
<td><%= $c->{usuario} %></td>
<td><%= $c->{data_abertura} %></td>
<td>
<a href="/chamados/<%= $c->{id} %>/editar">Editar</a>
<form method="post"
action="/chamados/<%= $c->{id} %>/excluir"
style="display:inline">
<button class="danger"
onclick="return confirm('Excluir chamado?')">
Excluir
</button>
</form>
</td>
</tr>
% }
</table>
@@ chamados/form.html.ep
% layout 'default';
% my $editando = $chamado ? 1 : 0;
<h1><%= $editando ? 'Editar chamado' : 'Novo chamado' %></h1>
<form method="post"
action="<%= $editando ? '/chamados/' . $chamado->{id} : '/chamados' %>">
<label>Título</label>
<input name="titulo" required
value="<%= $editando ? $chamado->{titulo} : '' %>">
<label>Descrição</label>
<textarea name="descricao" rows="6" required><%=
$editando ? $chamado->{descricao} : ''
%></textarea>
<label>Status</label>
<select name="status">
% for my $status (qw(Aberto Em_Andamento Fechado)) {
<option value="<%= $status %>"
<%= $editando && $chamado->{status} eq $status ? 'selected' : '' %>>
<%= $status %>
</option>
% }
</select>
<label>Usuário</label>
<select name="usuario_id" required>
% for my $u (@$usuarios) {
<option value="<%= $u->{id} %>"
<%= $editando && $chamado->{usuario_id} == $u->{id} ? 'selected' : '' %>>
<%= $u->{nome} %>
</option>
% }
</select>
<button type="submit">Salvar</button>
</form>
