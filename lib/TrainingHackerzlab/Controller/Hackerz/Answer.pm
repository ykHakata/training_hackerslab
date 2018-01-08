package TrainingHackerzlab::Controller::Hackerz::Answer;
use Mojo::Base 'TrainingHackerzlab::Controller::Base';

# 解答一覧画面
sub list {
    my $self = shift;
    $self->render(
        template => 'hackerz/answer/list',
        format   => 'html',
        handler  => 'ep',
        rows     => $self->_dummy_list_data(),
    );
    return;
}

# 解答結果画面
sub score {
    my $self = shift;
    $self->render( text => 'score' );
    return;
}

# 回答を送信したぞ画面
sub result {
    my $self    = shift;
    my $params  = +{ answer_id => $self->stash->{id}, };
    my $hackerz = $self->model->hackerz;
    my $answer  = $hackerz->answer->req_params($params);

    my $to_template_result = $answer->to_template_result;
    $self->stash(
        %{$to_template_result},
        template => 'hackerz/answer/result',
        format   => 'html',
        handler  => 'ep',
    );
    $self->render();
    return;
}

# 解答内容送信
sub store {
    my $self = shift;

    my $params          = $self->req->params->to_hash;
    my $question_params = +{ question_id => $params->{question_id}, };
    my $hackerz         = $self->model->hackerz;

    my $answer            = $hackerz->answer->req_params($params);
    my $question          = $hackerz->question->req_params($question_params);
    my $to_template_think = $question->to_template_think;
    my $template          = $question->select_template;

    $self->stash(
        %{$to_template_think},
        user    => $self->login_user->get_columns,
        format  => 'html',
        handler => 'ep',
    );

    # 簡易的なバリデート
    if ( $answer->has_error_easy ) {
        $self->stash( msg => $answer->error_msg );
        $self->render_fillin( $template, $params );
        return;
    }

    # DB 登録実行
    my $answer_id = $answer->store;

    # 書き込み保存終了、リダイレクト終了
    $self->flash( msg => '解答を送信しました' );
    $self->redirect_to("/hackerz/answer/$answer_id/result");
    return;
}

sub _dummy_list_data {
    my $self = shift;
    my $hash = [
        +{  question => 1,
            answer   => 'dddd',
        },
        +{  question => 2,
            answer   => 'sdffff',
        },
        +{  question => 3,
            answer   => 'tcp',
        },
    ];
    return $hash;
}

1;
