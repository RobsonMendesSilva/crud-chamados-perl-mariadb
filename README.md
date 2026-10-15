# CRUD de Chamados — Perl, Mojolicious e MariaDB

Projeto de estudo desenvolvido para praticar programação web com Perl, operações CRUD e modelagem de banco de dados relacional.

## Objetivo

Construir uma aplicação web simples para cadastrar e gerenciar usuários e chamados de suporte técnico.

## Tecnologias utilizadas

- **Perl** — linguagem de programação.
- **Mojolicious::Lite** — framework web.
- **DBI** — interface de acesso ao banco de dados.
- **MariaDB** — banco de dados relacional.
- **SQL** — criação das tabelas, restrições e relacionamento entre entidades.
- **HTML** — interface web.

## Funcionalidades

- Cadastro, consulta, edição e exclusão de usuários.
- Cadastro, consulta, edição e exclusão de chamados.
- Associação de chamados aos usuários cadastrados.
- Armazenamento dos dados no MariaDB.

## Modelagem do banco de dados

O banco utiliza duas tabelas principais:

### usuarios

| Campo | Descrição |
|---|---|
| id | Chave primária e identificador do usuário |
| nome | Nome do usuário |
| email | E-mail único do usuário |

### chamados

| Campo | Descrição |
|---|---|
| id | Chave primária do chamado |
| titulo | Título do chamado |
| descricao | Descrição do problema ou solicitação |
| status | Situação do chamado |
| data_abertura | Data e hora de abertura |
| usuario_id | Chave estrangeira que referencia usuarios.id |

O relacionamento é de um para muitos: um usuário pode estar associado a vários chamados.

A chave estrangeira ajuda a manter a integridade referencial dos dados.

## Estrutura do projeto

```text
crud-chamados/
├── app.pl
├── README.md
├── .gitignore
└── database/
    ├── criar_banco.sql
    └── dados_exemplo.sql
```

## Pré-requisitos

Em um ambiente Linux, instale Perl, MariaDB, o módulo DBI, o driver MySQL/MariaDB para DBI e Mojolicious.

Os nomes dos pacotes podem variar conforme a distribuição Linux.

No Linux Mint ou Ubuntu, os pacotes básicos podem ser instalados com:

```bash
sudo apt update
sudo apt install perl mariadb-server libdbi-perl libdbd-mysql-perl
```

O Mojolicious também precisa estar instalado no Perl utilizado pela aplicação.

## Configuração do banco de dados

Crie o banco e as tabelas usando o script:

```bash
sudo mariadb < database/criar_banco.sql
```

Crie um usuário próprio para a aplicação e conceda a ele permissões apenas sobre o banco `chamados_perl`. Configure a senha localmente e não a publique no GitHub.

## Dados de demonstração

Para inserir os registros fictícios, execute uma única vez, após criar o banco:

```bash
sudo mariadb < database/dados_exemplo.sql
```

O script de demonstração utiliza usuários e chamados fictícios.

## Configuração das variáveis de ambiente

Na mesma sessão do terminal em que a aplicação será executada, configure as variáveis com os dados do seu ambiente:

```bash
export DB_HOST=127.0.0.1
export DB_NAME=chamados_perl
export DB_USER=chamados_app
export DB_PASS='SUA_SENHA_LOCAL'
```

Substitua `SUA_SENHA_LOCAL` pela senha definida para o usuário do banco.

## Executando a aplicação

Entre na pasta do projeto e inicie o servidor de desenvolvimento:

```bash
cd ~/Projetos/Perl/crud-chamados
morbo app.pl
```

Acesse no navegador:

http://localhost:3000

O servidor de desenvolvimento `morbo` é adequado para estudos e testes locais.

## Aprendizados

Este projeto permite praticar:

- Rotas e formulários web com Mojolicious.
- Operações CRUD.
- Consultas SQL e integração Perl–MariaDB com DBI.
- Chaves primárias, chaves estrangeiras e restrições de unicidade.
- Separação entre aplicação, estrutura do banco e dados de demonstração.
- Configuração por variáveis de ambiente.

## Finalidade

Projeto educacional de portfólio, desenvolvido para consolidar conhecimentos em Perl, desenvolvimento web, SQL e administração de banco de dados.
