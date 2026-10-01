const express = require('express');
const multer = require('multer');
const router = express.Router();
const peluciaController = require('../controllers/peluciaController');

// Configura o Multer para armazenar em memória temporária para o Sharp processar
const upload = multer({ storage: multer.memoryStorage() });

// Rotas do CRUD de Produtos
router.get('/listar', peluciaController.listarPelucias);
router.get('/:id', peluciaController.obterPelucia);
router.post('/', peluciaController.criarPelucia);
router.put('/:id', peluciaController.atualizarPelucia);
router.delete('/:id', peluciaController.deletarPelucia);

// Rota para upload da imagem
router.post('/upload/:id', upload.single('imagem'), peluciaController.uploadImagem);

module.exports = router;