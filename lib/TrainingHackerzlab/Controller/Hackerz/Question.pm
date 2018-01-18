package TrainingHackerzlab::Controller::Hackerz::Question;
use Mojo::Base 'TrainingHackerzlab::Controller::Base';

# 各問題画面
sub think {
    my $self   = shift;
    my $params = +{
        question_id => $self->stash->{id},
        user_id     => $self->login_user->id,
    };
    my $model = $self->model->hackerz->question->req_params($params);
    my $to_template_think = $model->to_template_think;
    $self->stash(
        %{$to_template_think},
        template => $model->select_template,
        user     => $self->login_user->get_columns,
        format   => 'html',
        handler  => 'ep',
    );
    $self->render();
    return;
}

# 問題をとくんだな画面
sub index {
    my $self   = shift;
    my $params = +{ user_id => $self->login_user->id, };
    my $model  = $self->model->hackerz->question->req_params($params);
    my $to_template_index = $model->to_template_index;
    $self->stash(
        %{$to_template_index},
        user     => $self->login_user->get_columns,
        template => 'hackerz/question/index',
        format   => 'html',
        handler  => 'ep',
    );
    $self->render();
    return;
}

1;
