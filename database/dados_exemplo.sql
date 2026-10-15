
USE chamados_perl;

-- Usuarios ficticios para demonstracao
INSERT INTO usuarios (nome, email) VALUES
('Ana Oliveira', 'ana.exemplo@example.com'),
('Carlos Santos', 'carlos.exemplo@example.com'),
('Mariana Costa', 'mariana.exemplo@example.com');

-- Chamados ficticios para demonstracao
INSERT INTO chamados (titulo, descricao, status, usuario_id) VALUES
(
    'Problema de acesso ao sistema',
    'Usuario nao consegue acessar o sistema interno.',
    'Aberto',
    (SELECT id FROM usuarios WHERE email = 'ana.exemplo@example.com')
),
(
    'Solicitacao de instalacao',
    'Solicito a instalacao de um aplicativo de escritorio.',
    'Em_Andamento',
    (SELECT id FROM usuarios WHERE email = 'carlos.exemplo@example.com')
),
(
    'Configuracao de impressora',
    'Impressora configurada e testada com sucesso.',
    'Fechado',
    (SELECT id FROM usuarios WHERE email = 'mariana.exemplo@example.com')
);

