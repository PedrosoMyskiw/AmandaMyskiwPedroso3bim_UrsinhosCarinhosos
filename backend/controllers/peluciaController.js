const { query } = require('../database');
const fs = require('fs');
const path = require('path');
const sharp = require('sharp');

// Listar todos os produtos
exports.listarPelucias = async (req, res) => {
    try {
        const result = await query('SELECT * FROM public.pelucia ORDER BY id_pelucia');
        res.json({ sucesso: true, pelucias: result.rows });
    } catch (error) {
        console.error('Erro ao listar pelucias:', error);
        res.status(500).json({ sucesso: false, mensagem: 'Erro ao listar pelucias.' });
    }
};

// Obter produto por ID
exports.obterPelucia = async (req, res) => {
    try {
        const id = parseInt(req.params.id, 10);
        if (isNaN(id)) {
            return res.status(400).json({ sucesso: false, mensagem: 'ID inválido.' });
        }

        const result = await query('SELECT * FROM public.pelucia WHERE id_pelucia = $1', [id]);
        if (result.rows.length === 0) {
            return res.status(404).json({ sucesso: false, mensagem: 'Pelucia não encontrado.' });
        }

        res.json({ sucesso: true, pelucia: result.rows[0] });
    } catch (error) {
        console.error('Erro ao obter pelucia:', error);
        res.status(500).json({ sucesso: false, mensagem: 'Erro interno do servidor.' });
    }
};

// Criar produto
exports.criarPelucia = async (req, res) => {
    try {
        const { id_pelucia, nome_pelucia, id_formato, quantidade_estoque_pelucia, preco_unitario_pelucia } = req.body;

        if (!nome_pelucia) {
            return res.status(400).json({ sucesso: false, mensagem: 'O nome da pelucia é obrigatório.' });
        }

        const sql = `
            INSERT INTO public.pelucia (id_pelucia, nome_pelucia, id_formato, quantidade_estoque_pelucia, preco_unitario_pelucia)
            VALUES ($1, $2, $3, $4, $5)
            RETURNING *
        `;

        const values = [
            id_pelucia,
            nome_pelucia,
            id_formato || null,
            quantidade_estoque_pelucia || 0,
            preco_unitario_pelucia || 0.0
        ];

        const result = await query(sql, values);
        res.status(201).json({ sucesso: true, mensagem: 'Pelucia inserido com sucesso!', pelucia: result.rows[0] });
    } catch (error) {
        console.error('Erro ao criar pelucia:', error);
        if (error.code === '23503') {
            return res.status(400).json({ sucesso: false, mensagem: 'O formato informado não existe no cadastro.' });
        }
        res.status(500).json({ sucesso: false, mensagem: 'Erro ao inserir pelucia no banco de dados.' });
    }
};

// Atualizar produto
exports.atualizarPelucia = async (req, res) => {
    try {
        const id = parseInt(req.params.id, 10);
        const { nome_pelucia, id_formato, quantidade_estoque_pelucia, preco_unitario_pelucia } = req.body;

        const sql = `
            UPDATE public.pelucia 
            SET nome_pelucia = $1, 
                id_formato = $2, 
                quantidade_estoque_pelucia = $3, 
                preco_unitario_pelucia = $4 
            WHERE id_pelucia = $5
            RETURNING *
        `;

        const values = [
            nome_pelucia,
            id_formato || null,
            quantidade_estoque_pelucia || 0,
            preco_unitario_pelucia || 0.0,
            id
        ];

        const result = await query(sql, values);

        if (result.rows.length === 0) {
            return res.status(404).json({ sucesso: false, mensagem: 'Pelucia não encontrada.' });
        }

        res.json({ sucesso: true, mensagem: 'Pelucia alterada com sucesso!', pelucia: result.rows[0] });
    } catch (error) {
        console.error('Erro ao atualizar pelucia:', error);
        if (error.code === '23503') {
            return res.status(400).json({ sucesso: false, mensagem: 'O formato informado não existe no cadastro.' });
        }
        res.status(500).json({ sucesso: false, mensagem: 'Erro ao atualizar pelucia.' });
    }
};

// Upload e salvamento de imagem com Sharp
exports.uploadImagem = async (req, res) => {
    try {
        const id = req.params.id;
        if (!req.file) {
            return res.status(400).json({ sucesso: false, mensagem: 'Nenhum arquivo enviado.' });
        }

        const pastaImagens = path.join(__dirname, '../../imagens');
        if (!fs.existsSync(pastaImagens)) {
            fs.mkdirSync(pastaImagens, { recursive: true });
        }

        const caminhoDestino = path.join(pastaImagens, `${id}.png`);

        // Processa e converte para PNG no tamanho ideal
        await sharp(req.file.buffer)
            .resize(300, 300, { fit: 'cover' })
            .toFormat('png')
            .toFile(caminhoDestino);

        res.json({ sucesso: true, mensagem: 'Imagem salva com sucesso!' });
    } catch (error) {
        console.error('Erro ao salvar imagem:', error);
        res.status(500).json({ sucesso: false, mensagem: 'Erro ao processar imagem.' });
    }
};

// Deletar produto
exports.deletarPelucia = async (req, res) => {
    try {
        const id = parseInt(req.params.id, 10);

        await query('DELETE FROM public.pelucia WHERE id_pelucia = $1', [id]);

        const imgPath = path.join(__dirname, '../../imagens', `${id}.png`);
        if (fs.existsSync(imgPath)) {
            fs.unlinkSync(imgPath);
        }

        res.json({ sucesso: true, mensagem: 'Pelucia excluída com sucesso!' });
    } catch (error) {
        console.error('Erro ao deletar pelucia:', error);
        res.status(500).json({ sucesso: false, mensagem: 'Erro ao excluir pelucia.' });
    }
};