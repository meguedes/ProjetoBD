// ======================================================
// SISTEMA UNB - ACHADOS E PERDIDOS
// Página de Perfil
// ======================================================

// Recupera os dados do usuário logado
const usuario = JSON.parse(
    localStorage.getItem("usuarioLogado")
);

// Verifica se existe um usuário autenticado
if (!usuario) {

    alert("Faça login primeiro!");

    window.location.href = "/html/login.html";

} else {

    preencherPerfil();
}

// ======================================================
// EXIBIÇÃO DOS DADOS DO PERFIL
// ======================================================

function preencherPerfil(){

    document.getElementById("nomeUsuario").textContent =
        usuario.nome;

    document.getElementById("cpfUsuario").textContent =
        usuario.cpf;

    document.getElementById("emailUsuario").textContent =
        usuario.email;

    document.getElementById("telefoneUsuario").textContent =
        usuario.telefone;

    document.getElementById("registroUsuario").textContent =
        usuario.registro;

    document.getElementById("tipoUsuario").textContent =
        usuario.tipoUsuario;
}

// ======================================================
// EDITAR PERFIL
// ======================================================

document.getElementById("btnEditarPerfil")
.addEventListener("click", function(){

    document.getElementById("dadosPerfil").style.display = "none";

    const form = document.getElementById("formPerfil");

    form.innerHTML = `

        <div class="mb-2">
            <label class="form-label">Nome completo</label>
            <input type="text" class="form-control" id="edit-nome" value="${usuario.nome ?? ""}">
        </div>

        <div class="mb-2">
            <label class="form-label">Telefone</label>
            <input type="text" class="form-control" id="edit-telefone" value="${usuario.telefone ?? ""}">
        </div>

        <div class="mb-2">
            <label class="form-label">Registro institucional</label>
            <input type="text" class="form-control" id="edit-registro" value="${usuario.registro ?? ""}">
        </div>

        <div class="mb-2">
            <label class="form-label">Nova senha</label>
            <input type="password" class="form-control" id="edit-senha" placeholder="Deixe em branco para manter a mesma">
        </div>

        <div class="mb-3">
            <label class="form-label">Confirmar nova senha</label>
            <input type="password" class="form-control" id="edit-confirmar-senha">
        </div>

        <button class="btn btn-success" onclick="salvarEdicaoPerfil()">
            Salvar
        </button>

        <button class="btn btn-secondary ms-2" onclick="cancelarEdicaoPerfil()">
            Cancelar
        </button>

    `;

    form.style.display = "block";

});

function cancelarEdicaoPerfil(){

    document.getElementById("formPerfil").style.display = "none";
    document.getElementById("dadosPerfil").style.display = "block";

}

async function salvarEdicaoPerfil(){

    const nome = document.getElementById("edit-nome").value;
    const telefone = document.getElementById("edit-telefone").value;
    const registro = document.getElementById("edit-registro").value;
    const senha = document.getElementById("edit-senha").value;
    const confirmarSenha = document.getElementById("edit-confirmar-senha").value;

    if(!nome){
        alert("O nome não pode ficar vazio.");
        return;
    }

    if(senha && senha !== confirmarSenha){
        alert("As senhas não coincidem.");
        return;
    }

    const corpo = { nome, telefone, registro };
    if(senha){
        corpo.senha = senha;
    }

    try {

        const resposta = await fetch(
            `${API_BASE}/usuarios/${encodeURIComponent(usuario.cpf)}`,
            {
                method: "PUT",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(corpo)
            }
        );

        if(!resposta.ok){
            const dados = await resposta.json();
            alert(dados.erro || "Não foi possível salvar as alterações.");
            return;
        }

        // Atualiza a sessão local com os novos dados
        usuario.nome = nome;
        usuario.telefone = telefone;
        usuario.registro = registro;
        localStorage.setItem("usuarioLogado", JSON.stringify(usuario));

        preencherPerfil();
        cancelarEdicaoPerfil();

        alert("Perfil atualizado com sucesso!");

    } catch(erro){

        alert("Não foi possível conectar ao servidor. Verifique se a API está rodando.");

    }
}

// ======================================================
// EXCLUIR CONTA
// ======================================================

document.getElementById("btnExcluirConta")
.addEventListener("click", async function(){

    const confirmar = confirm(
        "Tem certeza que deseja excluir sua conta? Essa ação não pode ser desfeita."
    );

    if(!confirmar){
        return;
    }

    try {

        const resposta = await fetch(
            `${API_BASE}/usuarios/${encodeURIComponent(usuario.cpf)}`,
            { method: "DELETE" }
        );

        if(!resposta.ok){
            const dados = await resposta.json();
            alert(dados.erro || "Não foi possível excluir a conta.");
            return;
        }

        localStorage.removeItem("usuarioLogado");

        alert("Conta excluída com sucesso!");

        window.location.href = "/html/login.html";

    } catch(erro){

        alert("Não foi possível conectar ao servidor. Verifique se a API está rodando.");

    }

});

// Evento do botão "Sair"
document.getElementById("btnSair")
.addEventListener("click", async function () {

    // Avisa a API para encerrar a sessão no banco
    // (permite que a notificação de login volte a disparar)
    if(usuario){
        try {
            await fetch(`${API_BASE}/logout`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ cpf: usuario.cpf })
            });
        } catch(erro){
            // segue o logout mesmo se a API estiver fora do ar
        }
    }

    // Remove os dados da sessão
    localStorage.removeItem("usuarioLogado");

    // Retorna para a página inicial
    window.location.href = "/html/index.html";

});

// ======================================
// ESTATÍSTICAS DO PERFIL (via API)
// ======================================

async function carregarEstatisticas(){

    if(!usuario) return;

    const [respPostagens, respNotificacoes] = await Promise.all([
        fetch(`${API_BASE}/postagens?cpf=${encodeURIComponent(usuario.cpf)}`),
        fetch(`${API_BASE}/notificacoes/${encodeURIComponent(usuario.cpf)}`)
    ]);

    const postagens = await respPostagens.json();
    const notificacoes = await respNotificacoes.json();

    // Quantidade total de postagens
    document.getElementById("qtdPostagens").textContent =
    postagens.length;

    // Quantidade de objetos devolvidos
    const devolvidos = postagens.filter(post =>
        post.status_postagem === "Devolvido"
    );

    document.getElementById("qtdDevolvidos").textContent =
    devolvidos.length;

    // Quantidade de notificações
    document.getElementById("qtdNotificacoes").textContent =
    notificacoes.length;

}

carregarEstatisticas();

