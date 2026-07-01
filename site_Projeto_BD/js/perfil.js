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

    // Preenche os dados do perfil

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

