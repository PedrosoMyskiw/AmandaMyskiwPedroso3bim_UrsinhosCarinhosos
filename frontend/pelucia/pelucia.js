const URL_API = 'http://localhost:3001';
const SILHUETA_URL = `${URL_API}/imagens/silhueta.png`;

let oQueEstaFazendo = '';
let pelucia = null;
bloquearAtributos(true);

async function inicializar() {
    await carregarFormato();
    await listar();
}

async function carregarFormato() {
    const select = document.getElementById("selectId_formato");
    try {
        const resposta = await fetch(`${URL_API}/formato/listar`);
        const data = await resposta.json();
        if (data.sucesso) {
            select.innerHTML = '<option value="">-- Selecione um Formato --</option>';
            data.formatos.forEach(um => {
                select.innerHTML += `<option value="${um.id_formato}">${um.id_formato} - ${um.nome_formato}</option>`;
            });
        }
    } catch (erro) {
        select.innerHTML = '<option value="">Erro ao carregar formatos</option>';
    }
}

function carregarImagem(id) {
    const img = document.getElementById('imgPelucia');
    if (!id) {
        img.src = SILHUETA_URL;
        return;
    }
    img.src = `${URL_API}/imagens/${id}.png?t=${new Date().getTime()}`;
    img.onerror = () => { img.src = SILHUETA_URL; };
}

function acionarUpload() {
    if (oQueEstaFazendo !== 'inserindo' && oQueEstaFazendo !== 'alterando') {
        mostrarAviso("Clique em Inserir ou Alterar primeiro para poder escolher uma imagem.");
        return;
    }
    document.getElementById('inputImagem').click();
}

function previewImagem() {
    const inputFiles = document.getElementById('inputImagem').files;
    if (inputFiles.length > 0) {
        const url = URL.createObjectURL(inputFiles[0]);
        document.getElementById('imgPelucia').src = url;
        mostrarAviso("Imagem escolhida! Clique em Salvar para concluir.");
    }
}

async function uploadImagemParaServidor(id) {
    const inputFiles = document.getElementById('inputImagem').files;
    if (inputFiles.length === 0) return;

    const formData = new FormData();
    formData.append('imagem', inputFiles[0]);

    try {
        await fetch(`${URL_API}/pelucia/upload/${id}`, {
            method: 'POST',
            body: formData
        });
    } catch (erro) {
        console.error("Erro ao enviar imagem:", erro);
    }
}

async function procurePorChavePrimaria(chave) {
    try {
        const resposta = await fetch(`${URL_API}/pelucia/${chave}`);
        const data = await resposta.json();
        return data.sucesso ? data.pelucia : null;
    } catch (erro) {
        return null;
    }
}

async function procure() {
    const id_pelucia = document.getElementById("inputId_pelucia").value;
    if (isNaN(id_pelucia) || !Number.isInteger(Number(id_pelucia)) || id_pelucia === "") {
        mostrarAviso("Precisa ser um número inteiro");
        return;
    }

    pelucia = await procurePorChavePrimaria(id_pelucia);
    oQueEstaFazendo = '';
    
    if (pelucia) {
        mostrarDadosPelucia(pelucia);
        carregarImagem(id_pelucia);
        visibilidadeDosBotoes('inline', 'none', 'inline', 'inline', 'none');
        mostrarAviso("Achou no banco, pode alterar ou excluir");
    } else {
        limparAtributos();
        carregarImagem(null);
        visibilidadeDosBotoes('inline', 'inline', 'none', 'none', 'none');
        mostrarAviso("Não achou no banco, pode inserir");
    }
}

function inserir() {
    bloquearAtributos(false);
    visibilidadeDosBotoes('none', 'none', 'none', 'none', 'inline');
    oQueEstaFazendo = 'inserindo';
    mostrarAviso("INSERINDO - Digite os atributos, escolha a imagem e clique em salvar");
}

function alterar() {
    bloquearAtributos(false);
    visibilidadeDosBotoes('none', 'none', 'none', 'none', 'inline');
    oQueEstaFazendo = 'alterando';
    mostrarAviso("ALTERANDO - Digite os atributos, mude a imagem (opcional) e clique em salvar");
}

function excluir() {
    bloquearAtributos(true);
    visibilidadeDosBotoes('none', 'none', 'none', 'none', 'inline');
    oQueEstaFazendo = 'excluindo';
    mostrarAviso("EXCLUINDO - Clique em salvar para confirmar a exclusão");
}

async function salvar() {
    let id_pelucia = document.getElementById("inputId_pelucia").value;
    const nome_pelucia = document.getElementById("inputNome_pelucia").value;
    const id_formato = document.getElementById("selectId_formato").value || null;
    const quantidade_estoque_pelucia = parseInt(document.getElementById("inputQuantidade_estoque_pelucia").value) || 0;
    const preco_unitario_pelucia = parseFloat(document.getElementById("inputPreco_unitario_pelucia").value) || 0.0;

    const dadosPelucia = { id_pelucia: id_pelucia, nome_pelucia: nome_pelucia, id_formato: id_formato, quantidade_estoque_pelucia: quantidade_estoque_pelucia, preco_unitario_pelucia: preco_unitario_pelucia };

    try {
        if (oQueEstaFazendo === 'inserindo') {
            await fetch(`${URL_API}/pelucia`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(dadosPelucia) });
            await uploadImagemParaServidor(id_pelucia);
            mostrarAviso("Inserido no Banco de Dados com sucesso!");
        } else if (oQueEstaFazendo === 'alterando') {
            await fetch(`${URL_API}/pelucia/${id_pelucia}`, { method: 'PUT', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(dadosPelucia) });
            await uploadImagemParaServidor(id_pelucia);
            mostrarAviso("Alterado no Banco de Dados com sucesso!");
        } else if (oQueEstaFazendo === 'excluindo') {
            await fetch(`${URL_API}/pelucia/${id_pelucia}`, { method: 'DELETE' });
            carregarImagem(null);
            mostrarAviso("Excluído do Banco de Dados!");
        }

        visibilidadeDosBotoes('inline', 'none', 'none', 'none', 'none');
        limparAtributos();
        document.getElementById("inputId_pelucia").value = "";
        listar();
    } catch (erro) {
        mostrarAviso("Erro ao efetuar operação no servidor.");
    }
}

async function listar() {
    try {
        const resposta = await fetch(`${URL_API}/pelucia/listar`);
        const data = await resposta.json();
        if (data.sucesso) {
            let texto = "";
            for (let linha of data.pelucias) {
                const um = linha.id_formato ? ` [${linha.id_formato}]` : '';
                texto += `${linha.id_pelucia} - ${linha.nome_pelucia}${um} - Estoque: ${linha.quantidade_estoque_pelucia} - Preço: R$ ${parseFloat(linha.preco_unitario_pelucia).toFixed(2)}<br>`;
            }
            document.getElementById("outputSaida").innerHTML = texto || "Nenhuma pelucia cadastrada.";
        }
    } catch (erro) {
        document.getElementById("outputSaida").innerHTML = "Servidor offline.";
    }
}

function cancelarOperacao() {
    limparAtributos();
    carregarImagem(null);
    bloquearAtributos(true);
    visibilidadeDosBotoes('inline', 'none', 'none', 'none', 'none');
    mostrarAviso("Cancelou a operação");
}

function mostrarAviso(mensagem) {
    document.getElementById("divAviso").innerHTML = mensagem;
}

function mostrarDadosPelucia(p) {
    document.getElementById("inputId_pelucia").value = p.id_pelucia;
    document.getElementById("inputNome_pelucia").value = p.nome_pelucia;
    document.getElementById("selectId_formato").value = p.id_formato || "";
    document.getElementById("inputQuantidade_estoque_pelucia").value = p.quantidade_estoque_pelucia;
    document.getElementById("inputPreco_unitario_pelucia").value = p.preco_unitario_pelucia;
    bloquearAtributos(true);
}

function limparAtributos() {
    pelucia = null;
    oQueEstaFazendo = '';
    document.getElementById("inputNome_pelucia").value = "";
    document.getElementById("selectId_formato").value = "";
    document.getElementById("inputQuantidade_estoque_pelucia").value = "";
    document.getElementById("inputPreco_unitario_pelucia").value = "";
    document.getElementById("inputImagem").value = "";
    bloquearAtributos(true);
}

function bloquearAtributos(soLeitura) {
    document.getElementById("inputId_pelucia").readOnly = !soLeitura;
    document.getElementById("inputNome_pelucia").readOnly = soLeitura;
    document.getElementById("selectId_formato").disabled = soLeitura;
    document.getElementById("inputQuantidade_estoque_pelucia").readOnly = soLeitura;
    document.getElementById("inputPreco_unitario_pelucia").readOnly = soLeitura;
}

function visibilidadeDosBotoes(btP, btI, btA, btE, btS) {
    document.getElementById("btProcure").style.display = btP;
    document.getElementById("btInserir").style.display = btI;
    document.getElementById("btAlterar").style.display = btA;
    document.getElementById("btExcluir").style.display = btE;
    document.getElementById("btSalvar").style.display = btS;
    document.getElementById("btCancelar").style.display = btS;
}