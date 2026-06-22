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

    window.location.href = "login.html";

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
.addEventListener("click", function () {

    // Remove os dados da sessão
    localStorage.removeItem("usuarioLogado");

    // Retorna para a página inicial
    window.location.href = "index.html";

});