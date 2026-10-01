DROP TABLE IF EXISTS amigo, cargo, formato, forma_pagamento, cliente, funcionario, pelucia, pedido, pagamento, pedido_has_pelucia, pagamento_has_forma_pagamento;
-- ============================================
-- 1. CRIAÇÃO DAS TABELAS (REINO DOS URSINHOS)
-- ============================================

-- Tabelas sem dependências (primeiro)
CREATE TABLE public.amigo (
    cpf_amigo character varying(20) NOT NULL,
    nome_amigo character varying(60),
    data_nascimento_amigo date,
    endereco_amigo character varying(150),
    senha_amigo character varying(50),
    email_amigo character varying(75)
);

CREATE TABLE public.cargo (
    id_cargo integer NOT NULL,
    nome_cargo character varying(45)
);

CREATE TABLE public.formato (
    id_formato character varying(2) NOT NULL,
    nome_formato character varying(30)
);

CREATE TABLE public.forma_pagamento (
    id_forma_pagamento integer NOT NULL,
    nome_forma_pagamento character varying(100)
);

-- Tabelas de Herança de Amigo (1 dependência)
CREATE TABLE public.cliente (
    amigo_cpf_amigo character varying(20) NOT NULL,
    renda_cliente double precision,
    data_cadastro_cliente date
);

CREATE TABLE public.funcionario (
    amigo_cpf_amigo character varying(20) NOT NULL,
    salario_funcionario double precision,
    cargo_id_cargo integer,
    porcentagem_comissao_funcionario double precision
);

-- Tabela de Produtos (Pelúcias)
CREATE TABLE public.pelucia (
    id_pelucia integer NOT NULL,
    nome_pelucia character varying(45),
    quantidade_estoque_pelucia integer,
    preco_unitario_pelucia double precision,
    id_formato character varying(2)
);

-- Tabelas com múltiplas dependências
CREATE TABLE public.pedido (
    id_pedido integer NOT NULL,
    data_pedido date,
    cliente_amigo_cpf_amigo character varying(20),
    funcionario_amigo_cpf_amigo character varying(20)
);

CREATE TABLE public.pagamento (
    pedido_id_pedido integer NOT NULL,
    data_pagamento timestamp without time zone,
    valor_total_pagamento double precision
);

CREATE TABLE public.pedido_has_pelucia (
    pelucia_id_pelucia integer NOT NULL,
    pedido_id_pedido integer NOT NULL,
    quantidade integer,
    preco_unitario double precision
);

CREATE TABLE public.pagamento_has_forma_pagamento (
    pagamento_id_pedido integer NOT NULL,
    forma_pagamento_id_forma_pagamento integer NOT NULL,
    valor_pago double precision
);

-- ============================================
-- 2. SEQUENCES
-- ============================================

CREATE SEQUENCE public.cargo_id_cargo_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.forma_pagamento_id_forma_pagamento_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.pedido_id_pedido_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.pelucia_id_pelucia_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ============================================
-- 3. ALTERS PARA DEFAULTS DAS SEQUENCES
-- ============================================

ALTER SEQUENCE public.cargo_id_cargo_seq OWNED BY public.cargo.id_cargo;
ALTER SEQUENCE public.forma_pagamento_id_forma_pagamento_seq OWNED BY public.forma_pagamento.id_forma_pagamento;
ALTER SEQUENCE public.pedido_id_pedido_seq OWNED BY public.pedido.id_pedido;
ALTER SEQUENCE public.pelucia_id_pelucia_seq OWNED BY public.pelucia.id_pelucia;

ALTER TABLE ONLY public.cargo ALTER COLUMN id_cargo SET DEFAULT nextval('public.cargo_id_cargo_seq'::regclass);
ALTER TABLE ONLY public.forma_pagamento ALTER COLUMN id_forma_pagamento SET DEFAULT nextval('public.forma_pagamento_id_forma_pagamento_seq'::regclass);
ALTER TABLE ONLY public.pedido ALTER COLUMN id_pedido SET DEFAULT nextval('public.pedido_id_pedido_seq'::regclass);
ALTER TABLE ONLY public.pelucia ALTER COLUMN id_pelucia SET DEFAULT nextval('public.pelucia_id_pelucia_seq'::regclass);

-- ============================================
-- 4. CONSTRAINTS (CHAVES PRIMÁRIAS E ESTRANGEIRAS)
-- ============================================

ALTER TABLE ONLY public.amigo 
    ADD CONSTRAINT amigo_pkey PRIMARY KEY (cpf_amigo);

ALTER TABLE ONLY public.cargo 
    ADD CONSTRAINT cargo_pkey PRIMARY KEY (id_cargo);

ALTER TABLE ONLY public.formato 
    ADD CONSTRAINT formato_pkey PRIMARY KEY (id_formato);

ALTER TABLE ONLY public.forma_pagamento 
    ADD CONSTRAINT forma_pagamento_pkey PRIMARY KEY (id_forma_pagamento);

ALTER TABLE ONLY public.cliente 
    ADD CONSTRAINT cliente_pkey PRIMARY KEY (amigo_cpf_amigo);

ALTER TABLE ONLY public.funcionario 
    ADD CONSTRAINT funcionario_pkey PRIMARY KEY (amigo_cpf_amigo);

ALTER TABLE ONLY public.pelucia 
    ADD CONSTRAINT pelucia_pkey PRIMARY KEY (id_pelucia);

ALTER TABLE ONLY public.pedido 
    ADD CONSTRAINT pedido_pkey PRIMARY KEY (id_pedido);

ALTER TABLE ONLY public.pagamento 
    ADD CONSTRAINT pagamento_pkey PRIMARY KEY (pedido_id_pedido);

ALTER TABLE ONLY public.pedido_has_pelucia 
    ADD CONSTRAINT pedido_has_pelucia_pkey PRIMARY KEY (pelucia_id_pelucia, pedido_id_pedido);

ALTER TABLE ONLY public.pagamento_has_forma_pagamento 
    ADD CONSTRAINT pagamento_has_forma_pagamento_pkey PRIMARY KEY (pagamento_id_pedido, forma_pagamento_id_forma_pagamento);
	
-- Chaves Estrangeiras
-- Chaves Estrangeiras do Cliente e Funcionário (Herança de Amigo)
ALTER TABLE ONLY public.cliente 
    ADD CONSTRAINT fk_cliente_amigo FOREIGN KEY (amigo_cpf_amigo) REFERENCES public.amigo (cpf_amigo);

ALTER TABLE ONLY public.funcionario 
    ADD CONSTRAINT fk_funcionario_amigo FOREIGN KEY (amigo_cpf_amigo) REFERENCES public.amigo (cpf_amigo);

ALTER TABLE ONLY public.funcionario 
    ADD CONSTRAINT fk_funcionario_cargo FOREIGN KEY (cargo_id_cargo) REFERENCES public.cargo (id_cargo);

-- Chave Estrangeira do Formato na Pelúcia
ALTER TABLE ONLY public.pelucia 
    ADD CONSTRAINT fk_pelucia_formato FOREIGN KEY (id_formato) REFERENCES public.formato (id_formato);

-- Chaves Estrangeiras do Pedido
ALTER TABLE ONLY public.pedido 
    ADD CONSTRAINT fk_pedido_cliente FOREIGN KEY (cliente_amigo_cpf_amigo) REFERENCES public.cliente (amigo_cpf_amigo);

ALTER TABLE ONLY public.pedido 
    ADD CONSTRAINT fk_pedido_funcionario FOREIGN KEY (funcionario_amigo_cpf_amigo) REFERENCES public.funcionario (amigo_cpf_amigo);

-- Chave Estrangeira do Pagamento
ALTER TABLE ONLY public.pagamento 
    ADD CONSTRAINT fk_pagamento_pedido FOREIGN KEY (pedido_id_pedido) REFERENCES public.pedido (id_pedido);

-- Chaves Estrangeiras dos Itens do Pedido (Pelúcias)
ALTER TABLE ONLY public.pedido_has_pelucia 
    ADD CONSTRAINT fk_pedido_has_pelucia_pelucia FOREIGN KEY (pelucia_id_pelucia) REFERENCES public.pelucia (id_pelucia);

ALTER TABLE ONLY public.pedido_has_pelucia 
    ADD CONSTRAINT fk_pedido_has_pelucia_pedido FOREIGN KEY (pedido_id_pedido) REFERENCES public.pedido (id_pedido);

-- Chaves Estrangeiras das Formas de Pagamento
ALTER TABLE ONLY public.pagamento_has_forma_pagamento 
    ADD CONSTRAINT fk_pagamento_has_forma_pagamento_pagamento FOREIGN KEY (pagamento_id_pedido) REFERENCES public.pagamento (pedido_id_pedido);

ALTER TABLE ONLY public.pagamento_has_forma_pagamento 
    ADD CONSTRAINT fk_pagamento_has_forma_pagamento_forma_pagamento FOREIGN KEY (forma_pagamento_id_forma_pagamento) REFERENCES public.forma_pagamento (id_forma_pagamento);
	
-- ============================================
-- 5. INSERTS (ORDEM CORRETA DE DEPENDÊNCIA)
-- ============================================

-- 5.1 AMIGO (Antiga Pessoa - Temática: Ursinhos Carinhosos)
INSERT INTO public.amigo VALUES ('10101010101', 'Juliana Coração', '1989-10-25', 'Rua das Nuvens Algodão, 352', '1111', 'juliana@reindocarinho.com');
INSERT INTO public.amigo VALUES ('44444444444', 'Ana Carinhosa', '1995-04-25', 'Alameda das Estrelas Guia, 453 apto 13', '.123456', 'ana@reindocarinho.com');
INSERT INTO public.amigo VALUES ('55555555555', 'Lucas Brilhante', '1988-05-30', 'Avenida do Arco-Íris, 77 apto 101', '.123456', 'lucas@reindocarinho.com');
INSERT INTO public.amigo VALUES ('66666666666', 'Fernanda Alegria', '1993-06-05', 'Praça dos Raios de Sol, 243', '.123456', 'fernanda@reindocarinho.com');
INSERT INTO public.amigo VALUES ('77777777777', 'Ricardo Sorriso', '1987-07-10', 'Recanto da Magia, 34', '.123456', 'ricardo@reindocarinho.com');
INSERT INTO public.amigo VALUES ('88888888888', 'Patrícia Bondade', '1994-08-15', 'Bosque dos Sonhos, 54', '.123456', 'patricia@reindocarinho.com');
INSERT INTO public.amigo VALUES ('99999999999', 'Marcos Harmonia', '1991-09-20', 'Vale do Amor, 88', '.123456', 'marcos@reindocarinho.com');
INSERT INTO public.amigo VALUES ('22222222222', 'Maria Esperança', '1985-02-15', 'Estrada do Céu Azul, 1234', '.123456', 'maria@reindocarinho.com');
INSERT INTO public.amigo VALUES ('1', 'Ursinho Berola', '2025-10-16', 'Nuvem Rosa Mágica, s/n', '12345', 'berola@reindocarinho.com');
INSERT INTO public.amigo VALUES ('00000000000', 'Atendimento Mágico Online', '1900-01-01', 'Castelo das Nuvens', 'abc123', 'online@reindocarinho.com');
INSERT INTO public.amigo VALUES ('33333333333', 'Carlos Amizade', '1992-03-20', 'Travessa das Cores, 234', '123456x', 'carlos@reindocarinho.com');
INSERT INTO public.amigo VALUES ('11111111111', 'João Sorte', '2025-01-01', 'Vila do Carinho, 10', '123456x', 'joao@reindocarinho.com');
INSERT INTO public.amigo VALUES ('2', 'Ursinho Doce', '2025-10-07', 'Rua das Magnólias Encantadas, 12', '123456x', 'doce@reindocarinho.com');

-- 5.2 CARGO (Temática: Ursinhos Carinhosos)
INSERT INTO public.cargo VALUES (0, 'Espalhador de Sorrisos (Online)');
INSERT INTO public.cargo VALUES (1, 'Guardião de Abraços');
INSERT INTO public.cargo VALUES (2, 'Líder do Reino do Carinho');
INSERT INTO public.cargo VALUES (3, 'Tesoureiro das Estrelas');
INSERT INTO public.cargo VALUES (4, 'Guardião do Arco-Íris');
INSERT INTO public.cargo VALUES (5, 'Acolhedor Mágico');
INSERT INTO public.cargo VALUES (6, 'Organizador de Magia');
INSERT INTO public.cargo VALUES (7, 'Conferente de Raios Carinhosos');
INSERT INTO public.cargo VALUES (8, 'Aprendiz de Carinho');
INSERT INTO public.cargo VALUES (9, 'Auxiliar do Coração');
INSERT INTO public.cargo VALUES (10, 'Sábio Supremo da Nuvem Rosa');
INSERT INTO public.cargo VALUES (111, 'Protetor do Brilho Estelar');

-- 5.3 FORMATO (Antiga Unidade de Medida)
INSERT INTO public.formato VALUES ('UN', 'Unidade');
INSERT INTO public.formato VALUES ('KG', 'Quilograma');
INSERT INTO public.formato VALUES ('G', 'Grama');
INSERT INTO public.formato VALUES ('L', 'Litro');
INSERT INTO public.formato VALUES ('ML', 'Mililitro');
INSERT INTO public.formato VALUES ('CX', 'Caixa');
INSERT INTO public.formato VALUES ('PC', 'Pacote');

-- 5.4 FORMA_PAGAMENTO (Temática: Ursinhos Carinhosos)
INSERT INTO public.forma_pagamento VALUES (1, 'Moedas de Ouro Mágico');
INSERT INTO public.forma_pagamento VALUES (2, 'Cartão Arco-Íris Crédito');
INSERT INTO public.forma_pagamento VALUES (3, 'Cartão Arco-Íris Débito');
INSERT INTO public.forma_pagamento VALUES (4, 'Pix Mágico');
INSERT INTO public.forma_pagamento VALUES (5, 'Boleto Encantado');
INSERT INTO public.forma_pagamento VALUES (6, 'Cupom do Reino do Carinho');
INSERT INTO public.forma_pagamento VALUES (7, 'Transferência Estelar');
INSERT INTO public.forma_pagamento VALUES (8, 'Vale-Abraço');
INSERT INTO public.forma_pagamento VALUES (9, 'Crédito do Coração');
INSERT INTO public.forma_pagamento VALUES (10, 'Gift Card Nuvem Rosa');

-- 5.5 CLIENTE (Chaves alinhadas com a tabela amigo)
INSERT INTO public.cliente VALUES ('22222222222', 3200.00, '2024-01-02');
INSERT INTO public.cliente VALUES ('33333333333', 1800.00, '2024-01-03');
INSERT INTO public.cliente VALUES ('44444444444', 4000.00, '2024-01-04');
INSERT INTO public.cliente VALUES ('55555555555', 2100.00, '2024-01-05');
INSERT INTO public.cliente VALUES ('66666666666', 3500.00, '2024-01-06');
INSERT INTO public.cliente VALUES ('77777777777', 2700.00, '2024-01-07');
INSERT INTO public.cliente VALUES ('88888888888', 5000.00, '2024-01-08');
INSERT INTO public.cliente VALUES ('99999999999', 3800.00, '2024-01-09');
INSERT INTO public.cliente VALUES ('11111111111', 2500.00, NULL);
INSERT INTO public.cliente VALUES ('10101010101', 4500.00, '2024-01-10');
INSERT INTO public.cliente VALUES ('1', 1111.00, '2025-10-11');
INSERT INTO public.cliente VALUES ('2', 22222.00, '2025-10-15');

-- 5.6 FUNCIONARIO (Chaves vinculadas a amigo e aos cargos temáticos)
INSERT INTO public.funcionario VALUES ('22222222222', 3000.00, 2, 10); -- Líder do Reino do Carinho (Gerente)
INSERT INTO public.funcionario VALUES ('33333333333', 1500.00, 3, 3);  -- Tesoureiro das Estrelas (Caixa)
INSERT INTO public.funcionario VALUES ('44444444444', 2500.00, 4, 6);  -- Guardião do Arco-Íris (Supervisor)
INSERT INTO public.funcionario VALUES ('55555555555', 1800.00, 5, 4);  -- Acolhedor Mágico (Atendente)
INSERT INTO public.funcionario VALUES ('66666666666', 1600.00, 6, 2);  -- Organizador de Magia (Repositor)
INSERT INTO public.funcionario VALUES ('77777777777', 2200.00, 7, 5);  -- Conferente de Raios Carinhosos (Conferente)
INSERT INTO public.funcionario VALUES ('88888888888', 1900.00, 8, 3);  -- Aprendiz de Carinho (Assistente)
INSERT INTO public.funcionario VALUES ('99999999999', 2800.00, 9, 7);  -- Auxiliar do Coração (Auxiliar)
INSERT INTO public.funcionario VALUES ('10101010101', 5000.00, 2, 15); -- Líder do Reino do Carinho (Gerente Sr.)
INSERT INTO public.funcionario VALUES ('00000000000', 0.00, 0, 0);     -- Espalhador de Sorrisos Online (Sistema)
INSERT INTO public.funcionario VALUES ('1', 1111.00, 2, 1);             -- Líder do Reino do Carinho

-- 5.7 PELUCIA (Apenas os nomes foram alterados para a temática Ursinhos Carinhosos)
INSERT INTO public.pelucia VALUES (8, 'Ursinho do Coração', 40, 60, 'UN');
INSERT INTO public.pelucia VALUES (9, 'Ursinha Harmonia', 30, 85, 'UN');
INSERT INTO public.pelucia VALUES (4, 'Ursinho Boa Sorte', 80, 32, 'PC');
INSERT INTO public.pelucia VALUES (1, 'Ursinho Carinhoso Clássico', 100, 55, 'UN');
INSERT INTO public.pelucia VALUES (3, 'Ursinho Sol', 150, 10, 'UN');
INSERT INTO public.pelucia VALUES (5, 'Ursinho Zangado', 50, 70, 'L');
INSERT INTO public.pelucia VALUES (7, 'Ursinha Alegria', 300, 75, 'PC');
INSERT INTO public.pelucia VALUES (10, 'Ursinho Sonho', 20, 12, 'UN');
INSERT INTO public.pelucia VALUES (2, 'Ursinha Amor-Mágico', 200, 43, 'PC');
INSERT INTO public.pelucia VALUES (6, 'Ursinho Amigo', 60, 45, 'L');
INSERT INTO public.pelucia VALUES (50, 'Ursinho Estrela Radiante', 50, 50, 'UN');

-- 5.8 PEDIDO
INSERT INTO public.pedido VALUES (3, '2024-02-03', '55555555555', '66666666666');
INSERT INTO public.pedido VALUES (7, '2024-02-07', '44444444444', '33333333333');
INSERT INTO public.pedido VALUES (8, '2024-02-08', '66666666666', '55555555555');
INSERT INTO public.pedido VALUES (9, '2024-02-09', '88888888888', '77777777777');
INSERT INTO public.pedido VALUES (10, '2024-02-10', '10101010101', '99999999999');
INSERT INTO public.pedido VALUES (20, '2025-10-10', '33333333333', '22222222222');
INSERT INTO public.pedido VALUES (4, '2024-02-04', '99999999999', '88888888888');
INSERT INTO public.pedido VALUES (5, '2024-02-05', '33333333333', '10101010101');
INSERT INTO public.pedido VALUES (1, '2024-02-01', '44444444444', '22222222222');
INSERT INTO public.pedido VALUES (2, '2024-02-02', '11111111111', '44444444444');
INSERT INTO public.pedido VALUES (11, '2025-11-12', '11111111111', '00000000000');
INSERT INTO public.pedido VALUES (12, '2025-11-12', '1', '00000000000');
INSERT INTO public.pedido VALUES (13, '2025-11-13', '1', '00000000000');
INSERT INTO public.pedido VALUES (14, '2025-11-13', '1', '00000000000');
INSERT INTO public.pedido VALUES (15, '2025-11-13', '1', '00000000000');
INSERT INTO public.pedido VALUES (16, '2025-11-13', '1', '00000000000');
INSERT INTO public.pedido VALUES (17, '2025-11-13', '1', '00000000000');
INSERT INTO public.pedido VALUES (18, '2025-11-13', '1', '00000000000');
INSERT INTO public.pedido VALUES (19, '2025-11-13', '1', '00000000000');
INSERT INTO public.pedido VALUES (21, '2025-11-13', '1', '00000000000');
INSERT INTO public.pedido VALUES (22, '2025-11-13', '1', '00000000000');
INSERT INTO public.pedido VALUES (23, '2025-11-13', '1', '00000000000');
INSERT INTO public.pedido VALUES (24, '2025-11-13', '1', '00000000000');
INSERT INTO public.pedido VALUES (25, '2025-11-13', '1', '00000000000');
INSERT INTO public.pedido VALUES (26, '2025-11-13', '1', '00000000000');
INSERT INTO public.pedido VALUES (27, '2025-11-13', '1', '00000000000');
INSERT INTO public.pedido VALUES (28, '2025-11-13', '1', '00000000000');
INSERT INTO public.pedido VALUES (29, '2025-11-13', '1', '00000000000');
INSERT INTO public.pedido VALUES (30, '2025-11-13', '1', '00000000000');
INSERT INTO public.pedido VALUES (31, '2025-11-13', '1', '00000000000');
INSERT INTO public.pedido VALUES (32, '2025-11-13', '1', '00000000000');
INSERT INTO public.pedido VALUES (33, '2025-11-13', '1', '00000000000');
INSERT INTO public.pedido VALUES (34, '2025-11-13', '1', '00000000000');
INSERT INTO public.pedido VALUES (35, '2025-11-13', '1', '00000000000');
INSERT INTO public.pedido VALUES (36, '2025-11-13', '1', '00000000000');
INSERT INTO public.pedido VALUES (37, '2025-11-14', '1', '00000000000');
INSERT INTO public.pedido VALUES (38, '2025-11-14', '1', '00000000000');
INSERT INTO public.pedido VALUES (39, '2025-11-14', '1', '00000000000');
INSERT INTO public.pedido VALUES (40, '2025-11-14', '1', '00000000000');
INSERT INTO public.pedido VALUES (41, '2025-11-14', '1', '00000000000');
INSERT INTO public.pedido VALUES (42, '2025-11-15', '1', '00000000000');
INSERT INTO public.pedido VALUES (43, '2025-11-15', '1', '00000000000');
INSERT INTO public.pedido VALUES (44, '2025-11-15', '1', '00000000000');
INSERT INTO public.pedido VALUES (45, '2025-11-15', '1', '00000000000');
INSERT INTO public.pedido VALUES (46, '2025-11-15', '1', '00000000000');
INSERT INTO public.pedido VALUES (47, '2025-11-15', '1', '00000000000');
INSERT INTO public.pedido VALUES (48, '2025-11-16', '1', '00000000000');
INSERT INTO public.pedido VALUES (49, '2025-11-16', '1', '00000000000');
INSERT INTO public.pedido VALUES (50, '2025-11-16', '1', '00000000000');
INSERT INTO public.pedido VALUES (51, '2025-11-16', '1', '00000000000');
INSERT INTO public.pedido VALUES (52, '2025-11-16', '1', '00000000000');
INSERT INTO public.pedido VALUES (53, '2025-11-18', '1', '00000000000');
INSERT INTO public.pedido VALUES (54, '2025-11-18', '1', '00000000000');
INSERT INTO public.pedido VALUES (55, '2025-11-18', '1', '00000000000');
INSERT INTO public.pedido VALUES (56, '2025-11-20', '1', '00000000000');
INSERT INTO public.pedido VALUES (57, '2025-11-20', '1', '00000000000');
INSERT INTO public.pedido VALUES (58, '2025-11-20', '1', '00000000000');
INSERT INTO public.pedido VALUES (59, '2025-11-22', '1', '00000000000');
INSERT INTO public.pedido VALUES (60, '2025-11-23', '1', '00000000000');
INSERT INTO public.pedido VALUES (61, '2025-11-23', '1', '00000000000');
INSERT INTO public.pedido VALUES (62, '2025-12-13', '1', '00000000000');
INSERT INTO public.pedido VALUES (63, '2025-12-13', '1', '00000000000');
INSERT INTO public.pedido VALUES (64, '2025-12-13', '1', '00000000000');
INSERT INTO public.pedido VALUES (65, '2025-12-13', '1', '00000000000');
INSERT INTO public.pedido VALUES (66, '2025-12-13', '1', '00000000000');
INSERT INTO public.pedido VALUES (67, '2025-12-13', '1', '00000000000');
INSERT INTO public.pedido VALUES (68, '2025-12-13', '1', '00000000000');
INSERT INTO public.pedido VALUES (69, '2025-12-13', '1', '00000000000');
INSERT INTO public.pedido VALUES (70, '2025-12-13', '1', '00000000000');
INSERT INTO public.pedido VALUES (71, '2025-12-13', '1', '00000000000');
INSERT INTO public.pedido VALUES (72, '2025-12-13', '1', '00000000000');

-- 5.9 PAGAMENTO
INSERT INTO public.pagamento VALUES (1, '2024-02-01 10:00:00', 50);
INSERT INTO public.pagamento VALUES (2, '2024-02-02 11:00:00', 30);
INSERT INTO public.pagamento VALUES (3, '2024-02-03 12:00:00', 20);
INSERT INTO public.pagamento VALUES (4, '2024-02-04 13:00:00', 70);
INSERT INTO public.pagamento VALUES (5, '2024-02-05 14:00:00', 100);
INSERT INTO public.pagamento VALUES (7, '2024-02-07 16:00:00', 25);
INSERT INTO public.pagamento VALUES (8, '2024-02-08 17:00:00', 45);
INSERT INTO public.pagamento VALUES (9, '2024-02-09 18:00:00', 60);
INSERT INTO public.pagamento VALUES (10, '2024-02-10 19:00:00', 90);
INSERT INTO public.pagamento VALUES (64, '2025-12-13 08:07:02.875', 9.8);
INSERT INTO public.pagamento VALUES (65, '2025-12-13 08:58:10.097', 13);
INSERT INTO public.pagamento VALUES (66, '2025-12-13 09:00:47.612', 13);
INSERT INTO public.pagamento VALUES (71, '2025-12-13 09:12:45.255', 13.35);
INSERT INTO public.pagamento VALUES (72, '2025-12-13 09:15:50.149', 13.35);

-- 5.10 PEDIDO_HAS_PELUCIA (Antiga Pedido_has_Produto)
INSERT INTO public.pedido_has_pelucia VALUES (1, 1, 2, 5.5);
INSERT INTO public.pedido_has_pelucia VALUES (2, 2, 10, 0.5);
INSERT INTO public.pedido_has_pelucia VALUES (3, 2, 5, 1);
INSERT INTO public.pedido_has_pelucia VALUES (4, 2, 3, 3.2);
INSERT INTO public.pedido_has_pelucia VALUES (5, 5, 2, 7);
INSERT INTO public.pedido_has_pelucia VALUES (3, 1, 3, 1);
INSERT INTO public.pedido_has_pelucia VALUES (2, 3, 1, 0.5);
INSERT INTO public.pedido_has_pelucia VALUES (4, 4, 4, 4);
INSERT INTO public.pedido_has_pelucia VALUES (2, 1, 1000, 0.7);
INSERT INTO public.pedido_has_pelucia VALUES (2, 20, 1, 0.5);
INSERT INTO public.pedido_has_pelucia VALUES (1, 36, 100, 55);
INSERT INTO public.pedido_has_pelucia VALUES (3, 36, 100, 10);
INSERT INTO public.pedido_has_pelucia VALUES (8, 37, 200, 60);
INSERT INTO public.pedido_has_pelucia VALUES (10, 37, 100, 12);
INSERT INTO public.pedido_has_pelucia VALUES (2, 38, 100, 43);
INSERT INTO public.pedido_has_pelucia VALUES (7, 38, 100, 75);
INSERT INTO public.pedido_has_pelucia VALUES (6, 38, 100, 45);
INSERT INTO public.pedido_has_pelucia VALUES (4, 39, 100, 32);
INSERT INTO public.pedido_has_pelucia VALUES (5, 39, 100, 70);
INSERT INTO public.pedido_has_pelucia VALUES (6, 39, 100, 45);
INSERT INTO public.pedido_has_pelucia VALUES (1, 40, 100, 55);
INSERT INTO public.pedido_has_pelucia VALUES (2, 40, 100, 43);
INSERT INTO public.pedido_has_pelucia VALUES (3, 40, 100, 10);
INSERT INTO public.pedido_has_pelucia VALUES (4, 40, 100, 32);
INSERT INTO public.pedido_has_pelucia VALUES (5, 40, 100, 70);
INSERT INTO public.pedido_has_pelucia VALUES (1, 41, 100, 55);
INSERT INTO public.pedido_has_pelucia VALUES (3, 41, 100, 10);
INSERT INTO public.pedido_has_pelucia VALUES (4, 41, 100, 32);
INSERT INTO public.pedido_has_pelucia VALUES (10, 42, 100, 12);
INSERT INTO public.pedido_has_pelucia VALUES (2, 42, 100, 43);
INSERT INTO public.pedido_has_pelucia VALUES (3, 42, 100, 10);
INSERT INTO public.pedido_has_pelucia VALUES (1, 43, 100, 55);
INSERT INTO public.pedido_has_pelucia VALUES (2, 43, 100, 43);
INSERT INTO public.pedido_has_pelucia VALUES (3, 43, 100, 10);
INSERT INTO public.pedido_has_pelucia VALUES (2, 44, 1, 43);
INSERT INTO public.pedido_has_pelucia VALUES (3, 44, 1, 10);
INSERT INTO public.pedido_has_pelucia VALUES (3, 45, 1, 10);
INSERT INTO public.pedido_has_pelucia VALUES (2, 45, 4, 43);
INSERT INTO public.pedido_has_pelucia VALUES (3, 47, 100, 10);
INSERT INTO public.pedido_has_pelucia VALUES (2, 47, 1000, 43);
INSERT INTO public.pedido_has_pelucia VALUES (1, 48, 300, 55);
INSERT INTO public.pedido_has_pelucia VALUES (2, 48, 100, 43);
INSERT INTO public.pedido_has_pelucia VALUES (2, 49, 100, 43);
INSERT INTO public.pedido_has_pelucia VALUES (3, 49, 100, 10);
INSERT INTO public.pedido_has_pelucia VALUES (4, 49, 100, 32);
INSERT INTO public.pedido_has_pelucia VALUES (2, 50, 100, 43);
INSERT INTO public.pedido_has_pelucia VALUES (3, 50, 100, 10);
INSERT INTO public.pedido_has_pelucia VALUES (4, 50, 100, 32);
INSERT INTO public.pedido_has_pelucia VALUES (2, 51, 100, 43);
INSERT INTO public.pedido_has_pelucia VALUES (3, 51, 100, 10);
INSERT INTO public.pedido_has_pelucia VALUES (4, 51, 100, 32);
INSERT INTO public.pedido_has_pelucia VALUES (2, 52, 100, 43);
INSERT INTO public.pedido_has_pelucia VALUES (3, 52, 100, 10);
INSERT INTO public.pedido_has_pelucia VALUES (4, 52, 100, 32);
INSERT INTO public.pedido_has_pelucia VALUES (1, 53, 100, 55);
INSERT INTO public.pedido_has_pelucia VALUES (2, 53, 100, 43);
INSERT INTO public.pedido_has_pelucia VALUES (1, 54, 100, 55);
INSERT INTO public.pedido_has_pelucia VALUES (2, 54, 100, 43);
INSERT INTO public.pedido_has_pelucia VALUES (1, 55, 100, 55);
INSERT INTO public.pedido_has_pelucia VALUES (2, 55, 100, 43);
INSERT INTO public.pedido_has_pelucia VALUES (4, 56, 100, 32);
INSERT INTO public.pedido_has_pelucia VALUES (3, 56, 100, 10);
INSERT INTO public.pedido_has_pelucia VALUES (2, 57, 100, 43);
INSERT INTO public.pedido_has_pelucia VALUES (3, 57, 100, 10);
INSERT INTO public.pedido_has_pelucia VALUES (2, 58, 100, 43);
INSERT INTO public.pedido_has_pelucia VALUES (3, 58, 100, 10);
INSERT INTO public.pedido_has_pelucia VALUES (1, 59, 100, 55);
INSERT INTO public.pedido_has_pelucia VALUES (3, 59, 100, 10);
INSERT INTO public.pedido_has_pelucia VALUES (5, 60, 100, 70);
INSERT INTO public.pedido_has_pelucia VALUES (5, 61, 100, 70);
INSERT INTO public.pedido_has_pelucia VALUES (1, 62, 100, 55);
INSERT INTO public.pedido_has_pelucia VALUES (2, 62, 100, 43);
INSERT INTO public.pedido_has_pelucia VALUES (1, 63, 100, 55);
INSERT INTO public.pedido_has_pelucia VALUES (2, 63, 100, 43);
INSERT INTO public.pedido_has_pelucia VALUES (1, 64, 100, 55);
INSERT INTO public.pedido_has_pelucia VALUES (2, 64, 100, 43);
INSERT INTO public.pedido_has_pelucia VALUES (1, 65, 100, 55);
INSERT INTO public.pedido_has_pelucia VALUES (2, 65, 100, 43);
INSERT INTO public.pedido_has_pelucia VALUES (4, 65, 100, 32);
INSERT INTO public.pedido_has_pelucia VALUES (1, 66, 100, 55);
INSERT INTO public.pedido_has_pelucia VALUES (2, 66, 100, 43);

-- 5.11 PAGAMENTO_HAS_FORMA_PAGAMENTO
INSERT INTO public.pagamento_has_forma_pagamento VALUES (1, 1, 20);