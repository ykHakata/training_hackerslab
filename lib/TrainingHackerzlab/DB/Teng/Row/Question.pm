package TrainingHackerzlab::DB::Teng::Row::Question;
use Mojo::Base 'Teng::Row';
use Mojo::Util qw{dumper};

# 問題のヒントを取得
sub search_hint {
    my $self = shift;
    my $cond = +{ question_id => $self->id, deleted => 0, };
    my @rows = $self->handle->search( 'hint', $cond );
    return \@rows;
}

# 問題のヒントが開封ずみのヒントを取得
sub search_opened_hint {
    my $self    = shift;
    my $user_id = shift;

    # 問題のヒントを取得
    my $hint_rows = $self->search_hint;

    # ヒントの開封が存在するか
    return [ grep { $_->is_opened($user_id) } @{$hint_rows} ];
}

# 問題文に対しての選択を取得 (4択問題の場合)
sub search_choice {
    my $self = shift;
    my $cond = +{ question_id => $self->id, deleted => 0, };
    my @rows = $self->handle->search( 'choice', $cond );
    return \@rows;
}

# 問題文の解答が埋まっているページの情報 (調査する問題の場合)
sub fetch_survey {
    my $self = shift;
    my $cond = +{ question_id => $self->id, deleted => 0, };
    return $self->handle->single( 'survey', $cond );
}

# 該当の入力済みの解答を取得
sub fetch_answer {
    my $self    = shift;
    my $user_id = shift;
    my $cond    = +{
        user_id     => $user_id,
        question_id => $self->id,
        deleted     => 0,
    };
    return $self->handle->single( 'answer', $cond );
}

# この問題は解答済み
sub is_answer_ended {
    my $self    = shift;
    my $user_id = shift;
    my $cond    = +{
        user_id     => $user_id,
        question_id => $self->id,
        deleted     => 0,
    };
    my $answer = $self->handle->single( 'answer', $cond );
    return 1 if $answer;
    return;
}

1;

__END__

