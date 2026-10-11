-- Criação das tabelas
CREATE TABLE EVENTO (
	cp_id_evento BIGINT PRIMARY KEY NOT NULL,
	sg_evento VARCHAR(20) NOT NULL,
	nm_evento VARCHAR(200) NOT NULL,
	ds_evento TEXT NOT NULL,
	tp_evento VARCHAR NOT NULL
);

CREATE TABLE EDICAO (
	cp_id_edicao BIGINT PRIMARY KEY NOT NULL,
	ce_evento BIGINT NOT NULL,
	nr_edicao INT,
	ano_edicao SMALLINT NOT NULL,
	dt_inicio_evento DATE NOT NULL,
	dt_fim_evento DATE NOT NULL,
	dt_inicio_inscricao TIMESTAMP NOT NULL,
	dt_fim_inscricao TIMESTAMP NOT NULL,
	modalidade_evento VARCHAR NOT NULL,
	cidade_evento VARCHAR NOT NULL,
	uf_evento CHAR(2) NOT NULL,
	pais_evento CHAR(2) NOT NULL,
	FOREIGN KEY (ce_evento) REFERENCES EVENTO(cp_id_evento)
);

CREATE TABLE CATEGORIA_INSCRICAO (
	cp_id_categoria BIGINT PRIMARY KEY NOT NULL,
	ce_edicao BIGINT NOT NULL,
	nm_categoria VARCHAR(100) NOT NULL,
	ds_categoria TEXT NOT NULL,
	ind_exige_comprovacao BOOLEAN NOT NULL,
	FOREIGN KEY (ce_edicao) REFERENCES EDICAO(cp_id_edicao) 
);

CREATE TABLE FAIXA_INSCRICAO (
	cp_id_faixa BIGINT PRIMARY KEY NOT NULL,
	nm_faixa VARCHAR(60) NOT NULL,
	dt_inicio_faixa TIMESTAMP NOT NULL,
	dt_fim_faixa TIMESTAMP NOT NULL
);

CREATE TABLE PRECO_CATEGORIA_FAIXA (	
	ce_categoria BIGINT NOT NULL,
	ce_faixa BIGINT NOT NULL,	
	vl_preco_associado NUMERIC NOT NULL,
	vl_preco_nao_associado NUMERIC NOT NULL,
	FOREIGN KEY (ce_categoria) REFERENCES CATEGORIA_INSCRICAO(cp_id_categoria),	
	FOREIGN KEY (ce_faixa) REFERENCES FAIXA_INSCRICAO(cp_id_faixa)
);

CREATE TABLE PESSOA (
	cp_id_pessoa BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY NOT NULL,
	nm_pessoa VARCHAR(200) NOT NULL,
	cpf_pessoa CHAR(11),
	passaporte_pessoa VARCHAR(30),
	email_pessoa VARCHAR(254) NOT NULL,
	dt_nascimento DATE,
	pais_pessoa CHAR(2) NOT NULL
);

CREATE TABLE ASSOCIACAO (
	cp_matricula_sbtc BIGINT PRIMARY KEY NOT NULL,
	ce_pessoa BIGINT NOT NULL,
	dt_inicio_associacao TIMESTAMP NOT NULL,
	dt_fim_associacao TIMESTAMP NOT NULL,
	status_associacao VARCHAR NOT NULL,
	FOREIGN KEY (ce_pessoa) REFERENCES PESSOA(cp_id_pessoa)
);

CREATE TABLE INSCRICAO (
	cp_id_inscricao BIGINT PRIMARY KEY NOT NULL,
	ce_pessoa BIGINT NOT NULL,
	ce_categoria BIGINT NOT NULL,
	dt_inscricao TIMESTAMP NOT NULL,
	status_atual VARCHAR NOT NULL,
	status_anterior VARCHAR,
	dt_mudanca_status TIMESTAMP,
	vl_total_inscricao NUMERIC NOT NULL,
	dt_credenciamento TIMESTAMP,
	dt_confirmacao TIMESTAMP,
	dt_cancelamento TIMESTAMP,	
	FOREIGN KEY (ce_pessoa) REFERENCES PESSOA(cp_id_pessoa),	
	FOREIGN KEY (ce_categoria) REFERENCES CATEGORIA_INSCRICAO(cp_id_categoria) 
);

CREATE TABLE PAGAMENTO (
	cp_id_pagamento BIGINT PRIMARY KEY NOT NULL,
	ce_inscricao BIGINT NOT NULL,
	tp_pagamento VARCHAR NOT NULL,
	vl_pagamento NUMERIC NOT NULL,
	dt_criacao TIMESTAMP NOT NULL,
	dt_confirmacao TIMESTAMP,
	status_pagamento VARCHAR NOT NULL,
	cd_transacao_externa VARCHAR,	
	FOREIGN KEY (ce_inscricao) REFERENCES INSCRICAO(cp_id_inscricao)	
);

CREATE TABLE DOCUMENTO (
	cp_id_documento BIGINT PRIMARY KEY NOT NULL,
	ce_inscricao BIGINT NOT NULL,
	tp_documento VARCHAR NOT NULL,
	dt_envio TIMESTAMP NOT NULL,
	status_documento VARCHAR NOT NULL,
	dt_analise TIMESTAMP,
	ds_caminho_arquivo VARCHAR NOT NULL,	
	FOREIGN KEY (ce_inscricao) REFERENCES INSCRICAO(cp_id_inscricao)
);

CREATE TABLE CERTIFICADO (
	cp_id_certificado BIGINT PRIMARY KEY NOT NULL,
	ce_inscricao BIGINT NOT NULL,
	tp_certificado VARCHAR NOT NULL,
	dt_emissao TIMESTAMP NOT NULL,
	cd_validacao VARCHAR NOT NULL,
	nr_via INT NOT NULL,		
	FOREIGN KEY (ce_inscricao) REFERENCES INSCRICAO(cp_id_inscricao)
);

CREATE TABLE REEMBOLSO (
	cp_id_reembolso BIGINT PRIMARY KEY NOT NULL,	
	ce_inscricao BIGINT NOT NULL,
	dt_solicitacao TIMESTAMP NOT NULL,
	vl_reembolso NUMERIC NOT NULL,
	status_reembolso VARCHAR NOT NULL,
	FOREIGN KEY (ce_inscricao) REFERENCES INSCRICAO(cp_id_inscricao)
);



-- População da base de dados
DO $$
DECLARE
    v_i INT;
    v_id_evento BIGINT;
    v_id_edicao BIGINT;
    v_id_categoria BIGINT;
    v_id_faixa BIGINT;
    v_id_pessoa BIGINT;

    arr_siglas_evento TEXT[] := ARRAY['CONBRAS', 'SIMPCOMP', 'ENEM', 'WORKPR', 'SECOMP', 'LATAMINFO', 'CONEXAO', 'TECHSUM'];
    arr_nomes_evento TEXT[] := ARRAY['Congresso Brasileiro de Software', 'Simpósio de Computação', 'Encontro Nacional de Tecnologia', 'Workshop de Programação', 'Semana Acadêmica', 'Conferência Latino-Americana'];
    arr_tipos_evento TEXT[] := ARRAY['Congresso', 'Simpósio', 'Workshop', 'Seminário', 'Conferência'];

    arr_cidades TEXT[] := ARRAY['São Paulo', 'Rio de Janeiro', 'Belo Horizonte', 'Curitiba', 'Florianópolis', 'Salvador', 'Brasília', 'Porto Alegre', 'Recife', 'Fortaleza'];
    arr_ufs TEXT[] := ARRAY['SP', 'RJ', 'MG', 'PR', 'SC', 'BA', 'DF', 'RS', 'PE', 'CE'];

    arr_p_nome TEXT[] := ARRAY['Ana', 'Bruno', 'Carlos', 'Daniela', 'Eduardo', 'Fernanda', 'Gabriel', 'Helena', 'Igor', 'Juliana', 'Lucas', 'Mariana', 'Nicolas', 'Olivia', 'Pedro', 'Rafaela', 'Samuel', 'Tatiana', 'Victor', 'Yasmin'];
    arr_sobrenome TEXT[] := ARRAY['Silva', 'Santos', 'Oliveira', 'Souza', 'Lima', 'Costa', 'Almeida', 'Rocha', 'Martins', 'Barbosa', 'Ferreira', 'Alves', 'Pereira', 'Mendes', 'Carvalho', 'Gomes', 'Ribeiro', 'Teixeira', 'Cavalcante', 'Monteiro'];

    arr_status_insc TEXT[] := ARRAY['PENDENTE', 'CONFIRMADA', 'CANCELADA', 'CREDENCIADA'];
    arr_status_pag TEXT[] := ARRAY['PENDENTE', 'APROVADO', 'RECUSADO', 'ESTORNADO'];
    arr_tp_pag TEXT[] := ARRAY['PIX', 'CARTAO_CREDITO', 'BOLETO', 'TRANSFERENCIA'];
    arr_tp_doc TEXT[] := ARRAY['COMPROVANTE_ESTUDANTE', 'RG', 'CPF', 'CRACHA'];
    arr_status_doc TEXT[] := ARRAY['PENDENTE', 'APROVADO', 'REJEITADO'];
    arr_tp_cert TEXT[] := ARRAY['PARTICIPACAO', 'APRESENTACAO', 'ORGANIZACAO'];
    arr_status_assoc TEXT[] := ARRAY['ATIVA', 'INATIVA', 'SUSPENSA'];
    arr_status_reemb TEXT[] := ARRAY['SOLICITADO', 'EM_ANALISE', 'APROVADO', 'NEGADO', 'PAGO'];
BEGIN
    FOR v_i IN 1..50 LOOP
        INSERT INTO evento (cp_id_evento, sg_evento, nm_evento, ds_evento, tp_evento)
        VALUES (
            v_i,
            arr_siglas_evento[1 + (v_i % array_length(arr_siglas_evento, 1))] || '_' || v_i,
            arr_nomes_evento[1 + (v_i % array_length(arr_nomes_evento, 1))] || ' Edição ' || v_i,
            'Descrição detalhada sobre o evento acadêmico e tecnológico número ' || v_i,
            arr_tipos_evento[1 + (v_i % array_length(arr_tipos_evento, 1))]
        ) ON CONFLICT DO NOTHING;
    END LOOP;

    FOR v_i IN 1..200 LOOP
        v_id_evento := 1 + (v_i % 50);
        INSERT INTO edicao (cp_id_edicao, ce_evento, nr_edicao, ano_edicao, dt_inicio_evento, dt_fim_evento, dt_inicio_inscricao, dt_fim_inscricao, modalidade_evento, cidade_evento, uf_evento, pais_evento)
        VALUES (
            v_i,
            v_id_evento,
            (v_i % 10) + 1,
            2020 + (v_i % 7),
            (CURRENT_DATE + (v_i || ' days')::INTERVAL)::DATE,
            (CURRENT_DATE + ((v_i + 3) || ' days')::INTERVAL)::DATE,
            NOW() - ((30 - v_i % 20) || ' days')::INTERVAL,
            NOW() + (v_i || ' days')::INTERVAL,
            CASE WHEN v_i % 2 = 0 THEN 'PRESENCIAL' ELSE 'ONLINE' END,
            arr_cidades[1 + (v_i % array_length(arr_cidades, 1))],
            arr_ufs[1 + (v_i % array_length(arr_ufs, 1))],
            'BR'
        ) ON CONFLICT DO NOTHING;
    END LOOP;

    FOR v_i IN 1..300 LOOP
        v_id_edicao := 1 + (v_i % 200);
        INSERT INTO categoria_inscricao (cp_id_categoria, ce_edicao, nm_categoria, ds_categoria, ind_exige_comprovacao)
        VALUES (
            v_i,
            v_id_edicao,
            CASE (v_i % 4) 
                WHEN 0 THEN 'Estudante de Graduação' 
                WHEN 1 THEN 'Profissional / Pesquisador' 
                WHEN 2 THEN 'Estudante de Pós-Graduação' 
                ELSE 'Convidado / VIP' 
            END,
            'Categoria para segmentar os participantes do evento.',
            (v_i % 2 = 0)
        ) ON CONFLICT DO NOTHING;
    END LOOP;

    FOR v_i IN 1..4 LOOP
        INSERT INTO faixa_inscricao (cp_id_faixa, nm_faixa, dt_inicio_faixa, dt_fim_faixa)
        VALUES (
            v_i,
            'Lote ' || v_i,
            NOW() + ((v_i * 30 - 30) || ' days')::INTERVAL,
            NOW() + ((v_i * 30) || ' days')::INTERVAL
        ) ON CONFLICT DO NOTHING;
    END LOOP;

    FOR v_id_categoria IN 1..300 LOOP
        FOR v_id_faixa IN 1..4 LOOP
            INSERT INTO preco_categoria_faixa (ce_categoria, ce_faixa, vl_preco_associado, vl_preco_nao_associado)
            VALUES (
                v_id_categoria,
                v_id_faixa,
                50.00 + (v_id_categoria % 10) + (v_id_faixa * 20),
                100.00 + (v_id_categoria % 10) + (v_id_faixa * 30)
            ) ON CONFLICT DO NOTHING;
        END LOOP;
    END LOOP;

    FOR v_i IN 1..5000 LOOP
        INSERT INTO pessoa (nm_pessoa, cpf_pessoa, passaporte_pessoa, email_pessoa, dt_nascimento, pais_pessoa)
        VALUES (
            arr_p_nome[1 + (v_i % array_length(arr_p_nome, 1))] || ' ' || 
            arr_sobrenome[1 + ((v_i / 20) % array_length(arr_sobrenome, 1))] || ' ' || 
            arr_sobrenome[1 + ((v_i / 400) % array_length(arr_sobrenome, 1))],
            LPAD((10000000000 + v_i)::TEXT, 11, '0'),
            NULLIF(CASE WHEN v_i % 10 = 0 THEN 'AB' || v_i ELSE NULL END, ''),
            'usuario' || v_i || '@email.com',
            CURRENT_DATE - INTERVAL '20 years' - ((v_i % 15000) || ' days')::INTERVAL,
            'BR'
        ) RETURNING cp_id_pessoa INTO v_id_pessoa;

        IF v_i % 5 = 0 THEN
            INSERT INTO associacao (cp_matricula_sbtc, dt_inicio_associacao, dt_fim_associacao, status_associacao, ce_pessoa)
            VALUES (
                v_i * 100,
                NOW() - INTERVAL '1 year' - (v_i || ' days')::INTERVAL,
                NOW() + INTERVAL '1 year' + (v_i || ' days')::INTERVAL,
                arr_status_assoc[1 + (v_i % array_length(arr_status_assoc, 1))],
                v_id_pessoa
            ) ON CONFLICT DO NOTHING;
        END IF;

        INSERT INTO inscricao (
            cp_id_inscricao, ce_pessoa, ce_categoria, dt_inscricao, 
            status_atual, status_anterior, vl_total_inscricao, 
            dt_confirmacao, dt_cancelamento, dt_credenciamento, dt_mudanca_status
        )
        VALUES (
            v_i,
            v_id_pessoa, 
            1 + (v_i % 300),        
            NOW() - (v_i || ' hours')::INTERVAL,
            arr_status_insc[1 + (v_i % array_length(arr_status_insc, 1))],
            arr_status_insc[1 + ((v_i + 1) % array_length(arr_status_insc, 1))],
            150.00 + (v_i % 350),
            CASE WHEN v_i % 2 = 0 THEN NOW() - ((v_i - 1) || ' hours')::INTERVAL ELSE NULL END,
            CASE WHEN (v_i % array_length(arr_status_insc, 1)) = 2 THEN NOW() ELSE NULL END,
            CASE WHEN (v_i % array_length(arr_status_insc, 1)) = 3 THEN NOW() ELSE NULL END,
            NOW() - ((v_i % 60) || ' minutes')::INTERVAL
        ) ON CONFLICT DO NOTHING;
    END LOOP;

    FOR v_i IN 1..5000 LOOP
        INSERT INTO pagamento (cp_id_pagamento, ce_inscricao, tp_pagamento, vl_pagamento, dt_criacao, dt_confirmacao, status_pagamento, cd_transacao_externa)
        VALUES (
            v_i,
            v_i,
            arr_tp_pag[1 + (v_i % array_length(arr_tp_pag, 1))],
            150.00 + (v_i % 350),
            NOW() - (v_i || ' hours')::INTERVAL,
            NOW() - ((v_i - 1) || ' hours')::INTERVAL,
            arr_status_pag[1 + (v_i % array_length(arr_status_pag, 1))],
            'TX_EXT_' || v_i
        ) ON CONFLICT DO NOTHING;
    END LOOP;

    FOR v_i IN 1..1500 LOOP
        INSERT INTO documento (cp_id_documento, ce_inscricao, tp_documento, dt_envio, status_documento, dt_analise, ds_caminho_arquivo)
        VALUES (
            v_i,
            v_i,
            arr_tp_doc[1 + (v_i % array_length(arr_tp_doc, 1))],
            NOW() - (v_i || ' hours')::INTERVAL,
            arr_status_doc[1 + (v_i % array_length(arr_status_doc, 1))],
            NOW(),
            '/uploads/documentos/comprovante_' || v_i || '.pdf'
        ) ON CONFLICT DO NOTHING;
    END LOOP;

    FOR v_i IN 1..3000 LOOP
        INSERT INTO certificado (cp_id_certificado, ce_inscricao, tp_certificado, dt_emissao, cd_validacao, nr_via)
        VALUES (
            v_i,
            v_i,
            arr_tp_cert[1 + (v_i % array_length(arr_tp_cert, 1))],
            NOW(),
            'HASH_VALIDACAO_CERT_' || v_i || '_' || MD5(v_i::TEXT),
            1
        ) ON CONFLICT DO NOTHING;
    END LOOP;

    FOR v_i IN 1..500 LOOP
        INSERT INTO reembolso (cp_id_reembolso, ce_inscricao, dt_solicitacao, vl_reembolso, status_reembolso)
        VALUES (
            v_i,
            1 + (v_i * 3),
            NOW() - (v_i || ' days')::INTERVAL,
            100.00 + (v_i % 50),
            arr_status_reemb[1 + (v_i % array_length(arr_status_reemb, 1))]
        ) ON CONFLICT DO NOTHING;
    END LOOP;

END $$;



-- Exploração dos metadados
select *
from pagamento

select * 
from pessoa

select * 
from inscricao