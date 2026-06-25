// =====================================================
// CAPTURA DO FORMULÁRIO DE CADASTRO
// =====================================================

// Obtém o formulário de cadastro de usuário pelo ID
const form = document.getElementById("cadastroForm");

// =====================================================
// EVENTO DE ENVIO DO FORMULÁRIO
// =====================================================

// Executa quando o usuário clica no botão "Criar Conta"
form.addEventListener("submit", function(event){


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
// ARMAZENAMENTO TEMPORÁRIO DOS DADOS
// =====================================================

// Salva o objeto usuário no Local Storage do navegador.
// Futuramente estes dados serão persistidos no PostgreSQL.
localStorage.setItem(
    "usuario",
    JSON.stringify(usuario)
);

// =====================================================
// CONFIRMAÇÃO DE CADASTRO
// =====================================================

// Informa ao usuário que a conta foi criada com sucesso
alert("Conta criada com sucesso!");

// =====================================================
// REDIRECIONAMENTO PARA LOGIN
// =====================================================

// Após o cadastro, o usuário é enviado para a tela de login
window.location.href = "/html/login.html";


});
