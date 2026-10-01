const { query } = require('../database');

// Listar todas as unidades de medida
exports.listarFormatos = async (req, res) => {
    try {
        const result = await query('SELECT * FROM public.formato ORDER BY id_formato');
        res.json({ sucesso: true, formatos: result.rows });
    } catch (error) {
        console.error('Erro ao listar formatos:', error);
        res.status(500).json({ sucesso: false, mensagem: 'Erro ao listar formatos.' });
    }
};

// Obter unidade de medida por ID
exports.obterFormato = async (req, res) => {
    try {
        const id = req.params.id ? req.params.id.trim().toUpperCase() : '';
        if (!id || id.length > 2) {
            return res.status(400).json({ sucesso: false, mensagem: 'ID inválido (deve ter até 2 caracteres).' });
        }

        const result = await query('SELECT * FROM public.formato WHERE id_formato = $1', [id]);
        if (result.rows.length === 0) {
            return res.status(404).json({ sucesso: false, mensagem: 'Formato não encontrado.' });
        }

        res.json({ sucesso: true, formato: result.rows[0] });
    } catch (error) {
        console.error('Erro ao obter formato:', error);
        res.status(500).json({ sucesso: false, mensagem: 'Erro interno do servidor.' });
    }
};

// Criar unidade de medida
exports.criarFormato = async (req, res) => {
    try {
        const { id_formato, nome_formato } = req.body;
        const id = id_formato ? id_formato.trim().toUpperCase() : '';

        if (!id || id.length > 2) {
            return res.status(400).json({ sucesso: false, mensagem: 'A sigla/ID deve ter até 2 caracteres.' });
        }

        if (!nome_formato) {
            return res.status(400).json({ sucesso: false, mensagem: 'O nome do formato é obrigatório.' });
        }

        const sql = `
            INSERT INTO public.formato (id_formato, nome_formato)
            VALUES ($1, $2)
            RETURNING *
        `;

        const result = await query(sql, [id, nome_formato]);
        res.status(201).json({ sucesso: true, mensagem: 'Formato inserido com sucesso!', formato: result.rows[0] });
    } catch (error) {
        console.error('Erro ao criar formato:', error);
        if (error.code === '23505') {
            return res.status(400).json({ sucesso: false, mensagem: 'Esta sigla de formato já está cadastrada.' });
        }
        res.status(500).json({ sucesso: false, mensagem: 'Erro ao inserir formato no banco de dados.' });
    }
};

// Atualizar unidade de medida
exports.atualizarFormato = async (req, res) => {
    try {
        const id = req.params.id ? req.params.id.trim().toUpperCase() : '';
        const { nome_formato } = req.body;

        if (!id || id.length > 2) {
            return res.status(400).json({ sucesso: false, mensagem: 'ID inválido.' });
        }

        const sql = `
            UPDATE public.formato 
            SET nome_formato = $1 
            WHERE id_formato = $2
            RETURNING *
        `;

        const result = await query(sql, [nome_formato, id]);

        if (result.rows.length === 0) {
            return res.status(404).json({ sucesso: false, mensagem: 'Formato não encontrado.' });
        }

        res.json({ sucesso: true, mensagem: 'Formato alterado com sucesso!', formato: result.rows[0] });
    } catch (error) {
        console.error('Erro ao atualizar formato:', error);
        res.status(500).json({ sucesso: false, mensagem: 'Erro ao atualizar formato.' });
    }
};

// Deletar unidade de medida
exports.deletarFormato = async (req, res) => {
    try {
        const id = req.params.id ? req.params.id.trim().toUpperCase() : '';

        if (!id || id.length > 2) {
            return res.status(400).json({ sucesso: false, mensagem: 'ID inválido.' });
        }

        await query('DELETE FROM public.formato WHERE id_formato = $1', [id]);

        res.json({ sucesso: true, mensagem: 'Formato excluído com sucesso!' });
    } catch (error) {
        console.error('Erro ao deletar formato:', error);
        if (error.code === '23503') {
            return res.status(400).json({ sucesso: false, mensagem: 'Não é possível excluir: existem pelucias associadas a este formato.' });
        }
        res.status(500).json({ sucesso: false, mensagem: 'Erro ao excluir formato.' });
    }
};