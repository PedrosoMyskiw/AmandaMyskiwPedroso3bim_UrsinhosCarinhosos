const URL_API = 'http://localhost:3001';

let oQueEstaFazendo = '';
let formato = null;
bloquearAtributos(true);

async function procurePorChavePrimaria(chave) {
    try {
        const resposta = await fetch(`${URL_API}/formato/${chave}`);
        const data = await resposta.json();
        return data.sucesso ? data.formato : null;
    } catch (erro) {
        return null;
    }
}

async function procure() {
    const id_formato = document.getElementById("inputId_formato").value.trim().toUpperCase();
    if (!id_formato || id_formato.length > 2) {
        mostrarAviso("O ID/Sigla deve conter de 1 a 2 caracteres (ex: CX, UN).");
        return;
    }

    document.getElementById("inputId_formato").value = id_formato;
    formato = await procurePorChavePrimaria(id_formato);
    oQueEstaFazendo = '';
    
    if (formato) {
        mostrarDadosFormato(formato);
        visibilidadeDosBotoes('inline', 'none', 'inline', 'inline', 'none');
        mostrarAviso("Achou no banco, pode alterar ou excluir");
    } else {
        limparAtributos();
        visibilidadeDosBotoes('inline', 'inline', 'none', 'none', 'none');
        mostrarAviso("Não achou no banco, pode inserir");
    }
}

function inserir() {
    bloquearAtributos(false);
    visibilidadeDosBotoes('none', 'none', 'none', 'none', 'inline');
    oQueEstaFazendo = 'inserindo';
    mostrarAviso("INSERINDO - Digite o nome do formato e clique em salvar");
}

function alterar() {
    bloquearAtributos(false);
    visibilidadeDosBotoes('none', 'none', 'none', 'none', 'inline');
    oQueEstaFazendo = 'alterando';
    mostrarAviso("ALTERANDO - Digite o novo nome e clique em salvar");
}

function excluir() {
    bloquearAtributos(true);
    visibilidadeDosBotoes('none', 'none', 'none', 'none', 'inline');
    oQueEstaFazendo = 'excluindo';
    mostrarAviso("EXCLUINDO - Clique em salvar para confirmar a exclusão");
}

async function salvar() {
    const id_formato = document.getElementById("inputId_formato").value.trim().toUpperCase();
    const nome_formato = document.getElementById("inputNome_formato").value;

    const dadosFormato = { id_formato: id_formato, nome_formato: nome_formato };

    try {
        if (oQueEstaFazendo === 'inserindo') {
            const resp = await fetch(`${URL_API}/formato`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(dadosFormato) });
            const data = await resp.json();
            if (!data.sucesso) return mostrarAviso(data.mensagem);
            mostrarAviso("Inserido no Banco de Dados com sucesso!");
        } else if (oQueEstaFazendo === 'alterando') {
            const resp = await fetch(`${URL_API}/formato/${id_formato}`, { method: 'PUT', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(dadosFormato) });
            const data = await resp.json();
            if (!data.sucesso) return mostrarAviso(data.mensagem);
            mostrarAviso("Alterado no Banco de Dados com sucesso!");
        } else if (oQueEstaFazendo === 'excluindo') {
            const resposta = await fetch(`${URL_API}/formato/${id_formato}`, { method: 'DELETE' });
            const data = await resposta.json();
            if (!data.sucesso) {
                mostrarAviso(data.mensagem || "Erro ao excluir no servidor.");
                return;
            }
            mostrarAviso("Excluído do Banco de Dados!");
        }

        visibilidadeDosBotoes('inline', 'none', 'none', 'none', 'none');
        limparAtributos();
        document.getElementById("inputId_formato").value = "";
        listar();
    } catch (erro) {
        mostrarAviso("Erro ao efetuar operação no servidor.");
    }
}

async function listar() {
    try {
        const resposta = await fetch(`${URL_API}/formato/listar`);
        const data = await resposta.json();
        
        if (data.sucesso) {
            let texto = "";
            for (let linha of data.formatos) {
                texto += `<b>[${linha.id_formato}]</b> - ${linha.nome_formato}<br>`;
            }
            document.getElementById("outputSaida").innerHTML = texto || "Nenhum formato cadastrado.";
        } else {
            document.getElementById("outputSaida").innerHTML = `Erro no banco: ${data.mensagem}`;
        }
    } catch (erro) {
        console.error("Erro ao listar:", erro);
        document.getElementById("outputSaida").innerHTML = "Servidor offline ou erro de conexão (CORS).";
    }
}

function cancelarOperacao() {
    limparAtributos();
    bloquearAtributos(true);
    visibilidadeDosBotoes('inline', 'none', 'none', 'none', 'none');
    mostrarAviso("Cancelou a operação");
}

function mostrarAviso(mensagem) {
    document.getElementById("divAviso").innerHTML = mensagem;
}

function mostrarDadosFormato(u) {
    document.getElementById("inputId_formato").value = u.id_formato;
    document.getElementById("inputNome_formato").value = u.nome_formato;
    bloquearAtributos(true);
}

function limparAtributos() {
    formato = null;
    oQueEstaFazendo = '';
    document.getElementById("inputNome_formato").value = "";
    bloquearAtributos(true);
}

function bloquearAtributos(soLeitura) {
    document.getElementById("inputId_formato").readOnly = !soLeitura;
    document.getElementById("inputNome_formato").readOnly = soLeitura;
}

function visibilidadeDosBotoes(btP, btI, btA, btE, btS) {
    document.getElementById("btProcure").style.display = btP;
    document.getElementById("btInserir").style.display = btI;
    document.getElementById("btAlterar").style.display = btA;
    document.getElementById("btExcluir").style.display = btE;
    document.getElementById("btSalvar").style.display = btS;
    document.getElementById("btCancelar").style.display = btS;
}