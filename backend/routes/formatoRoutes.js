const express = require('express');
const router = express.Router();
const formatoController = require('../controllers/formatoController');

// Rotas do CRUD de Unidades de Medida
router.get('/listar', formatoController.listarFormatos);
router.get('/:id', formatoController.obterFormato);
router.post('/', formatoController.criarFormato);
router.put('/:id', formatoController.atualizarFormato);
router.delete('/:id', formatoController.deletarFormato);

module.exports = router;