// Obtém o formulário de login pelo ID
const form = document.getElementById("loginForm");

// Adiciona um evento que será executado quando o formulário for enviado
form.addEventListener("submit", async function(event){

    // Impede o comportamento padrão do formulário
    // (recarregar a página ao enviar)
    event.preventDefault();

    // Captura o email digitado pelo usuário
    const emailDigitado =
        document.getElementById("email").value;

    // Captura a senha digitada pelo usuário
    const senhaDigitada =
        document.getElementById("senha").value;

    try {

        // Consulta a API, que valida as credenciais no PostgreSQL
        const resposta = await fetch(`${API_BASE}/login`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                email: emailDigitado,
                senha: senhaDigitada
            })
        });

        const usuario = await resposta.json();

        if(!resposta.ok){
            alert(usuario.erro || "Email ou senha inválidos!");
            return;
        }

        // Salva o usuário logado no localStorage
        // (apenas cache local da sessão, não é a fonte de verdade)
        localStorage.setItem(
            "usuarioLogado",
            JSON.stringify(usuario)
        );

        // Informa que o login foi realizado com sucesso
        alert("Login realizado com sucesso!");

        // Redireciona o usuário para a página de perfil
        window.location.href = "/html/perfil.html";

    } catch(erro){

        alert("Não foi possível conectar ao servidor. Verifique se a API está rodando.");

    }

});