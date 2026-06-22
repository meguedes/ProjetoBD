// Obtém o formulário de login pelo ID
const form = document.getElementById("loginForm");

// Adiciona um evento que será executado quando o formulário for enviado
form.addEventListener("submit", function(event){

    // Impede o comportamento padrão do formulário
    // (recarregar a página ao enviar)
    event.preventDefault();

    // Captura o email digitado pelo usuário
    const emailDigitado =
        document.getElementById("email").value;

    // Captura a senha digitada pelo usuário
    const senhaDigitada =
        document.getElementById("senha").value;

    // Recupera os dados do usuário armazenados no localStorage
    // e converte de JSON para objeto JavaScript
    const usuario = JSON.parse(
        localStorage.getItem("usuario")
    );

    // Verifica se existe algum usuário cadastrado
    if(!usuario){

        // Exibe mensagem de aviso
        alert("Nenhum usuário cadastrado!");

        // Encerra a execução da função
        return;
    }

    // Verifica se o email e a senha digitados
    // correspondem aos dados cadastrados
    if(
        emailDigitado === usuario.email &&
        senhaDigitada === usuario.senha
    ){

        // Salva o usuário como logado no localStorage
        localStorage.setItem(
            "usuarioLogado",
            JSON.stringify(usuario)
        );

        // Informa que o login foi realizado com sucesso
        alert("Login realizado com sucesso!");

        // Redireciona o usuário para a página de perfil
        window.location.href = "perfil.html";

    }else{

        // Exibe mensagem caso os dados estejam incorretos
        alert("Email ou senha inválidos!");

    }

});