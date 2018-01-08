package TrainingHackerzlab::Model::Hackerz::Question;
use Mojo::Base 'TrainingHackerzlab::Model::Base';

has [
    qw{is_question_choice is_question_form is_question_survey
        is_question_survey_and_file is_question_explain select_template}
] => undef;

# 問題画面パラメーター
sub to_template_think {
    my $self = shift;

    my $think = +{
        question => undef,
        hint     => undef,
        choice   => undef,
        survey   => undef,
    };

    my $cond = +{
        id      => $self->req_params->{question_id},
        deleted => 0,
    };

    # 存在しない問題の場合
    $self->select_template('hackerz/question/not_found');

    my $question_row = $self->db->teng->single( 'question', $cond );
    return $think if !$question_row;
    $think->{question} = $question_row->get_columns;

    $self->_analysis_pattern($question_row);
    my $hint_rows = $question_row->search_hint;
    my $hint      = +{};
    for my $hint_row ( @{$hint_rows} ) {
        $hint->{ $hint_row->level } = $hint_row->hint;
    }
    $think->{hint} = $hint;

    # 問題文に対して入力フォームにテキスト入力で解答
    return $think if $self->is_question_form;

    # 問題文に対して答えを4択から選択して解答
    return $self->_create_choice_params( $question_row, $think )
        if $self->is_question_choice;

    # 調査するページから解答を導き出して解答
    return $self->_create_survey_params( $question_row, $think )
        if $self->is_question_survey;

    # 調査するページとファイルダウンロード
    return $self->_create_survey_params( $question_row, $think )
        if $self->is_question_survey_and_file;

    # 問題と詳細から解答を導き出してテキスト入力で解答
    return $think if $self->is_question_explain;

    return $think;
}

# 選択する答えのリスト
sub _create_choice_params {
    my $self        = shift;
    my $row         = shift;
    my $think       = shift;
    my $choice_rows = $row->search_choice;
    my $choice      = +{};
    for my $choice_row ( @{$choice_rows} ) {
        $choice->{ $choice_row->answer_val } = $choice_row->answer_text;
    }
    $think->{choice} = $choice;
    return $think;
}

# 調査するページの情報
sub _create_survey_params {
    my $self       = shift;
    my $row        = shift;
    my $think      = shift;
    my $survey_row = $row->fetch_survey;
    return $think if !$survey_row;
    $think->{survey} = $survey_row->get_columns;
    return $think;
}

sub _analysis_pattern {
    my $self = shift;
    my $row  = shift;
    $self->select_template(undef);

    # form -> 問題文に対して入力フォームにテキスト入力
    if ( $row->pattern eq 10 ) {
        $self->is_question_form(1);
        $self->select_template('/hackerz/question/form');
        return;
    }

    # choice -> 問題文に対して答えを4択から選択して解答
    if ( $row->pattern eq 20 ) {
        $self->is_question_choice(1);
        $self->select_template('/hackerz/question/choice');
        return;
    }

    # survey -> 調査するページから解答を導き出して入力
    if ( $row->pattern eq 30 ) {
        $self->is_question_survey(1);
        $self->select_template('/hackerz/question/survey');
        return;
    }

    # survey_and_file -> 調査するページとファイル
    if ( $row->pattern eq 31 ) {
        $self->is_question_survey_and_file(1);
        $self->select_template('/hackerz/question/survey_and_file');
        return;
    }

    # explain -> 問題とその詳細から解答を導き出して入力
    if ( $row->pattern eq 40 ) {
        $self->is_question_explain(1);
        $self->select_template('/hackerz/question/explain');
        return;
    }
    return;
}

1;
