// ======================================================
// SISTEMA UNB - ACHADOS E PERDIDOS
// Página de Notificações
// ======================================================

// ------------------------------------------------------
// 1. VERIFICAÇÃO DE AUTENTICAÇÃO
// ------------------------------------------------------
// Recupera os dados do usuário armazenados no
// LocalStorage. Caso não exista um usuário
// autenticado, o acesso à página é bloqueado
// e o usuário é redirecionado para a tela de login.

const usuario = JSON.parse(
    localStorage.getItem("usuarioLogado")
);

if(!usuario){

    alert("Faça login para acessar suas notificações.");

    window.location.href = "/html/login.html";

}

// ------------------------------------------------------
// 2. CARREGAMENTO DAS NOTIFICAÇÕES
// ------------------------------------------------------
// Recupera as notificações armazenadas no
// LocalStorage.
//
// Futuramente estas informações serão obtidas
// do banco de dados PostgreSQL através do Flask.
//
// Caso ainda não existam notificações,
// um vetor vazio será utilizado.

const notificacoes = JSON.parse(
    localStorage.getItem("notificacoes")
) || [];

// ------------------------------------------------------
// 3. REFERÊNCIA AO ELEMENTO HTML
// ------------------------------------------------------
// Obtém o container onde as notificações serão
// exibidas dinamicamente.

const container =
document.getElementById("listaNotificacoes");

// ------------------------------------------------------
// 4. VERIFICA SE EXISTEM NOTIFICAÇÕES
// ------------------------------------------------------
// Caso o usuário ainda não possua notificações,
// é exibida uma mensagem informativa indicando
// que novas atividades aparecerão futuramente.

if(notificacoes.length === 0){

    container.innerHTML = `

        <div class="text-center text-muted py-5">

            <h4>

                🔔 Nenhuma notificação

            </h4>

            <p>

                Quando houver novas mensagens,
                alterações nas suas publicações
                ou outras atividades importantes,
                elas aparecerão aqui.

            </p>

        </div>

    `;

}else{

    // --------------------------------------------------
    // 5. EXIBIÇÃO DAS NOTIFICAÇÕES
    // --------------------------------------------------
    // Percorre todas as notificações armazenadas
    // e cria dinamicamente um card para cada uma.

    notificacoes.forEach(notificacao =>{

        container.innerHTML += `

            <div class="notificacao-card">

                <!-- Mensagem da notificação -->
                <p>

                    ${notificacao.mensagem}

                </p>

                <!-- Data ou horário da ocorrência -->
                <span class="data">

                    ${notificacao.data}

                </span>

            </div>

        `;

    });

}

// ------------------------------------------------------
// FUNCIONAMENTO DO SISTEMA
// ------------------------------------------------------
//
// 1. O sistema verifica se existe um usuário
//    autenticado no LocalStorage.
//
// 2. Caso o usuário não esteja logado,
//    o acesso à página é bloqueado e ele é
//    redirecionado para a tela de login.
//
// 3. As notificações são carregadas do
//    LocalStorage.
//
// 4. Se não houver notificações cadastradas,
//    é exibida uma mensagem informando que
//    nenhuma atividade foi encontrada.
//
// 5. Caso existam notificações, cada uma
//    é exibida dinamicamente na página.
//
// Futuramente:
//
// - As notificações serão recuperadas do
//   PostgreSQL através do Flask;
// - Novas mensagens recebidas;
// - Alterações de status das postagens;
// - Confirmações de devolução;
// - Outras atividades importantes do sistema.
//
// Dessa forma, a página já está preparada
// para a integração com o backend sem a
// necessidade de alterações na interface.
// ------------------------------------------------------