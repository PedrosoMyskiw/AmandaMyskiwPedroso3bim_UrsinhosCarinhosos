const express = require('express');
const router = express.Router();
const amigoController = require('../controllers/amigoController');

// CRUD de Pessoas

router.get('/abrirCrudAmigo', amigoController.abrirCrudAmigo);
router.get('/', amigoController.listarAmigos);
router.post('/', amigoController.criarAmigo);
router.get('/:id', amigoController.obterAmigo);
router.put('/:id', amigoController.atualizarAmigo);
router.delete('/:id', amigoController.deletarAmigo);

module.exports = router;
