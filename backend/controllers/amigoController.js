const { query } = require('../database');
const path = require('path');

exports.abrirCrudAmigo = (req, res) => {
  const usuario = req.cookies ? req.cookies.usuarioLogado : null;
  if (usuario) {
    res.sendFile(path.join(__dirname, '../../frontend/amigo/amigo.html'));
  } else {
    res.redirect('/login');
  }
};

exports.listarAmigos = async (req, res) => {
  try {
    const result = await query('SELECT * FROM amigo ORDER BY cpf_amigo');
    res.json({ sucesso: true, amigos: result.rows });
  } catch (error) {
    console.error('Erro ao listar amigos:', error);
    res.status(500).json({ sucesso: false, mensagem: 'Erro interno do servidor' });
  }
};

exports.criarAmigo = async (req, res) => {
  try {
    const { cpf_amigo, nome_amigo, data_nascimento_amigo, endereco_amigo, senha_amigo, email_amigo } = req.body;

    if (!nome_amigo || !endereco_amigo || !senha_amigo || !email_amigo) {
      return res.status(400).json({
        sucesso: false,
        mensagem: 'Nome, email, endereço e senha são obrigatórios'
      });
    }

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email_amigo)) {
      return res.status(400).json({
        sucesso: false,
        mensagem: 'Formato de email inválido'
      });
    }

    const result = await query(
      'INSERT INTO amigo (cpf_amigo, nome_amigo, data_nascimento_amigo, endereco_amigo, senha_amigo, email_amigo) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *',
      [cpf_amigo, nome_amigo, data_nascimento_amigo, endereco_amigo, senha_amigo, email_amigo]
    );

    res.status(201).json({ sucesso: true, amigo: result.rows[0] });
  } catch (error) {
    console.error('Erro ao criar amigo:', error);

    if (error.code === '23505' && error.constraint === 'amigo_unique') {
      return res.status(400).json({
        sucesso: false,
        mensagem: 'Email já está em uso'
      });
    }

    if (error.code === '23502') {
      return res.status(400).json({
        sucesso: false,
        mensagem: 'Dados obrigatórios não fornecidos'
      });
    }

    res.status(500).json({ sucesso: false, mensagem: 'Erro interno do servidor' });
  }
};

exports.obterAmigo = async (req, res) => {
  try {
    const id = parseInt(req.params.id);

    if (isNaN(id)) {
      return res.status(400).json({ sucesso: false, mensagem: 'CPF deve ser um número válido' });
    }

    const result = await query(
      'SELECT * FROM amigo WHERE cpf_amigo = $1',
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ sucesso: false, mensagem: 'Amigo não encontrada' });
    }

    res.json({ sucesso: true, amigo: result.rows[0] });
  } catch (error) {
    console.error('Erro ao obter amigo:', error);
    res.status(500).json({ sucesso: false, mensagem: 'Erro interno do servidor' });
  }
};

exports.atualizarAmigo = async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    const { nome_amigo, data_nascimento_amigo, endereco_amigo, senha_amigo, email_amigo } = req.body;

    if (email_amigo) {
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      if (!emailRegex.test(email_amigo)) {
        return res.status(400).json({
          sucesso: false,
          mensagem: 'Formato de email inválido'
        });
      }
    }

    const existingPersonResult = await query(
      'SELECT * FROM amigo WHERE cpf_amigo = $1',
      [id]
    );

    if (existingPersonResult.rows.length === 0) {
      return res.status(404).json({ sucesso: false, mensagem: 'Amigo não encontrada' });
    }

    const currentPerson = existingPersonResult.rows[0];
    const updatedFields = {
      nome_amigo: nome_amigo !== undefined ? nome_amigo : currentPerson.nome_amigo,
      data_nascimento_amigo: data_nascimento_amigo !== undefined ? data_nascimento_amigo : currentPerson.data_nascimento_amigo,
      endereco_amigo: endereco_amigo !== undefined ? endereco_amigo : currentPerson.endereco_amigo,
      senha_amigo: senha_amigo !== undefined ? senha_amigo : currentPerson.senha_amigo,
      email_amigo: email_amigo !== undefined ? email_amigo : currentPerson.email_amigo
    };

    const updateResult = await query(
      'UPDATE amigo SET nome_amigo = $1, data_nascimento_amigo = $2, endereco_amigo = $3, senha_amigo = $4, email_amigo = $5 WHERE cpf_amigo = $6 RETURNING *',
      [updatedFields.nome_amigo, updatedFields.data_nascimento_amigo, updatedFields.endereco_amigo, updatedFields.senha_amigo, updatedFields.email_amigo, id]
    );

    res.json({ sucesso: true, amigo: updateResult.rows[0] });
  } catch (error) {
    console.error('Erro ao atualizar amigo:', error);

    if (error.code === '23505' && error.constraint === 'amigo_unique') {
      return res.status(400).json({
        sucesso: false,
        mensagem: 'Email já está em uso por outro amigo'
      });
    }

    res.status(500).json({ sucesso: false, mensagem: 'Erro interno do servidor' });
  }
};

exports.deletarAmigo = async (req, res) => {
  try {
    const id = parseInt(req.params.id);

    const existingPersonResult = await query(
      'SELECT * FROM amigo WHERE cpf_amigo = $1',
      [id]
    );

    if (existingPersonResult.rows.length === 0) {
      return res.status(404).json({ sucesso: false, mensagem: 'Amigo não encontrado' });
    }

    await query(
      'DELETE FROM amigo WHERE cpf_amigo = $1',
      [id]
    );

    res.json({ sucesso: true, mensagem: 'Amigo excluída com sucesso' });
  } catch (error) {
    console.error('Erro ao deletar amigo:', error);

    if (error.code === '23503') {
      return res.status(400).json({
        sucesso: false,
        mensagem: 'Não é possível deletar amigo com dependências associadas'
      });
    }

    res.status(500).json({ sucesso: false, mensagem: 'Erro interno do servidor' });
  }
};

exports.obterAmigoPorEmail = async (req, res) => {
  try {
    const { email_amigo } = req.params;

    if (!email_amigo) {
      return res.status(400).json({ sucesso: false, mensagem: 'Email é obrigatório' });
    }

    const result = await query(
      'SELECT * FROM amigo WHERE email_amigo = $1',
      [email_amigo]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ sucesso: false, mensagem: 'Amigo não encontrada' });
    }

    res.json({ sucesso: true, amigo: result.rows[0] });
  } catch (error) {
    console.error('Erro ao obter amigo por email:', error);
    res.status(500).json({ sucesso: false, mensagem: 'Erro interno do servidor' });
  }
};

exports.atualizarSenha = async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    const { senha_atual, nova_senha } = req.body;

    if (isNaN(id)) {
      return res.status(400).json({ sucesso: false, mensagem: 'ID deve ser um número válido' });
    }

    if (!senha_atual || !nova_senha) {
      return res.status(400).json({ sucesso: false, mensagem: 'Senha atual e nova senha são obrigatórias' });
    }

    const personResult = await query(
      'SELECT * FROM amigo WHERE cpf_amigo = $1',
      [id]
    );

    if (personResult.rows.length === 0) {
      return res.status(404).json({ sucesso: false, mensagem: 'Amigo não encontrado' });
    }

    const person = personResult.rows[0];

    if (person.senha_amigo !== senha_atual) {
      return res.status(400).json({ sucesso: false, mensagem: 'Senha atual incorreta' });
    }

    const updateResult = await query(
      'UPDATE amigo SET senha_amigo = $1 WHERE cpf_amigo = $2 RETURNING cpf_amigo, nome_amigo, endereco_amigo, data_nascimento_amigo',
      [nova_senha, id]
    );

    res.json({ sucesso: true, amigo: updateResult.rows[0] });
  } catch (error) {
    console.error('Erro ao atualizar senha:', error);
    res.status(500).json({ sucesso: false, mensagem: 'Erro interno do servidor' });
  }
};