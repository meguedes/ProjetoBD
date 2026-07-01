// =====================================================
// CAPTURA DO FORMULÁRIO DE CADASTRO
// =====================================================

// Obtém o formulário de cadastro de usuário pelo ID
const form = document.getElementById("cadastroForm");

// =====================================================
// EVENTO DE ENVIO DO FORMULÁRIO
// =====================================================

// Executa quando o usuário clica no botão "Criar Conta"
form.addEventListener("submit", async function(event){


// Impede o comportamento padrão do formulário
// (recarregar a página após o envio)
event.preventDefault();

// =====================================================
// CAPTURA DOS DADOS INFORMADOS PELO USUÁRIO
// =====================================================

// Nome completo do usuário
const nome = document.querySelector('[name="nome"]').value;

// E-mail utilizado para login e contato
const email = document.querySelector('[name="email"]').value;

// CPF do usuário
const cpf = document.querySelector('[name="cpf"]').value;

// Telefone para contato
const telefone = document.querySelector('[name="telefone"]').value;

// Tipo de vínculo com a universidade
const tipoUsuario = document.querySelector('[name="tipo_usuario"]').value;

// Registro institucional (matrícula ou SIAPE)
const registro = document.querySelector('[name="registro"]').value;

// Senha escolhida pelo usuário
const senha = document.querySelector('[name="senha"]').value;

// Campo de confirmação da senha
const confirmarSenha = document.querySelector('[name="confirmar_senha"]').value;

// =====================================================
// VALIDAÇÃO DAS SENHAS
// =====================================================

// Verifica se a senha e a confirmação são iguais
if(senha !== confirmarSenha){

    // Exibe mensagem de erro
    alert("As senhas não coincidem!");

    // Interrompe a execução
    return;
}

// =====================================================
// CRIAÇÃO DO OBJETO USUÁRIO
// =====================================================

// Agrupa todas as informações do usuário em um objeto
const usuario = {

    cpf,
    nome,
    email,
    registro,
    telefone,
    tipoUsuario,
    senha
};

// =====================================================
// ENVIO DOS DADOS PARA A API (PERSISTÊNCIA NO POSTGRESQL)
// =====================================================

try {

    const resposta = await fetch(`${API_BASE}/usuarios`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(usuario)
    });

    const dados = await resposta.json();

    if(!resposta.ok){
        alert(dados.erro || "Não foi possível criar a conta.");
        return;
    }

    // =====================================================
    // CONFIRMAÇÃO DE CADASTRO
    // =====================================================

    alert("Conta criada com sucesso!");

    // =====================================================
    // REDIRECIONAMENTO PARA LOGIN
    // =====================================================

    window.location.href = "/html/login.html";

} catch(erro){

    alert("Não foi possível conectar ao servidor. Verifique se a API está rodando.");

}


});
