package TrainingHackerzlab::Model::Hackerz::Answer;
use Mojo::Base 'TrainingHackerzlab::Model::Base';
use Mojo::Util qw{dumper};
has [qw{error_msg}] => undef;

# 簡易的なバリデート
sub has_error_easy {
    my $self   = shift;
    my $params = $self->req_params;
    my $master = $self->db->master;
    $self->error_msg( $master->answer->to_word('NOT_INPUT') );
    return 1 if !$params->{user_id};
    return 1 if !$params->{user_answer};
    return 1 if !$params->{question_id};
    my $collected_id = $params->{collected_id} || '';

    # 二重登録防止
    my $cond = +{
        user_id      => $params->{user_id},
        question_id  => $params->{question_id},
        collected_id => $collected_id,
        deleted      => $self->db->master->deleted->constant('NOT_DELETED'),
    };
    my $answer = $self->db->teng->single( 'answer', $cond );
    $self->error_msg( $master->answer->to_word('EXISTS_ANSWER') );
    return 1 if $answer;
    $self->error_msg(undef);
    return;
}

# 解答結果点数
sub to_template_score {
    my $self    = shift;
    my $master  = $self->db->master;
    my $user_id = $self->req_params->{user_id};
    my $score   = +{
        result         => 0,
        list           => [],
        collected_list => undef,
    };

    # my $score = +{
    #     collected_list => [
    #         +{  collected     => +{},
    #             question_list => [
    #                 +{  collected_sort => +{},
    #                     question       => +{},
    #                     answer         => +{},
    #                     q_url          => '',
    #                     how            => '',
    #                     how_text       => '',
    #                 },
    #             ],
    #         },
    #         +{},
    #     ],
    # };
    my $user_row = $self->db->teng->single(
        'user',
        +{  id      => $user_id,
            deleted => 0,
        }
    );
    my $collected_list = $user_row->fetch_collected_list_to_hash();
    for my $list ( @{$collected_list} ) {
        for my $question_list ( @{ $list->{question_list} } ) {
            my $sort_id = $question_list->{collected_sort}->{sort_id};
            my $collected_id
                = $question_list->{collected_sort}->{collected_id};
            $question_list->{sort_id}      = $sort_id;
            $question_list->{collected_id} = $collected_id;

            # 短くした問題文章
            $question_list->{short_question}
                = substr( $question_list->{question}->{question}, 0, 20 )
                . ' ...';

            # 問題へのurl
            $question_list->{q_url}
                = "/hackerz/question/collected/$collected_id/$sort_id/think";

            # 問題の解答状況
            $question_list->{how}      = '未';
            $question_list->{how_text} = 'primary';

            if ( exists $question_list->{answer} ) {
                $question_list->{how}      = '不正解';
                $question_list->{how_text} = 'danger';
                if ( $question_list->{answer}->{user_answer} eq
                    $question_list->{question}->{answer} )
                {
                    $question_list->{how}      = '正解';
                    $question_list->{how_text} = 'success';
                }
            }
        }
    }
    $score->{collected_list} = $collected_list;

    my $cond = +{
        user_id => $user_id,
        deleted => 0,
    };

    # 解答入力済み
    my @answer_rows = $self->db->teng->search( 'answer', $cond );
    return $score if scalar @answer_rows eq 0;

    # ヒントの開封履歴 (下書き)
    my $list = [];
    for my $answer_row (@answer_rows) {

        my $question_row = $answer_row->fetch_question;
        my $data         = +{
            question_id       => $question_row->id,
            question_score    => $question_row->score,
            answer_result     => '不正解',
            hint_opened_level => [],
            get_score         => 0,
        };

        # 問題のヒントが開封ずみのヒントを取得
        my $hint_rows = $question_row->search_opened_hint($user_id);
        $data->{hint_opened_level} = [ map { $_->level } @{$hint_rows} ];

        # 不正解の場合は 0 点
        if ( $answer_row->is_correct ) {

            # ヒントの開封を考慮した獲得点数
            $data->{get_score} = $answer_row->get_score_opened_hint($user_id);
            $data->{answer_result} = '正解';
        }
        push @{$list}, $data;
    }
    $score->{list} = $list;

    # 獲得点数の計算
    my $total_score = 0;
    for my $row ( @{$list} ) {
        $total_score += $row->{get_score};
    }
    $score->{result} = $total_score;
    return $score;
}

# 登録実行
sub store {
    my $self   = shift;
    my $master = $self->db->master;
    my $params = +{
        question_id  => $self->req_params->{question_id},
        collected_id => $self->req_params->{collected_id},
        user_id      => $self->req_params->{user_id},
        user_answer  => $self->req_params->{user_answer},
        deleted      => $master->deleted->constant('NOT_DELETED'),
    };
    return $self->db->teng_fast_insert( 'answer', $params );
}

sub to_template_list {
    my $self   = shift;
    my $master = $self->db->master;
    my $list   = +{ answers => [], };

    my $cond = +{
        id      => $self->req_params->{user_id},
        deleted => $master->deleted->constant('NOT_DELETED'),
    };
    my $user_row = $self->db->teng->single( 'user', $cond );
    return $list if !$user_row;

    my $answer_rows = $user_row->search_answer;
    return $list if !$answer_rows;

    $list->{answers} = [ map { $_->get_columns } @{$answer_rows} ];
    return $list;
}

sub to_template_result {
    my $self   = shift;
    my $master = $self->db->master;
    my $result = +{};

    my $cond = +{
        id      => $self->req_params->{answer_id},
        deleted => 0,
    };

    my $answer_row = $self->db->teng->single( 'answer', $cond );
    return if !$answer_row;
    $result->{answer} = $answer_row->get_columns;

    my $question_row = $answer_row->fetch_question;

    if ( $answer_row->user_answer eq $question_row->answer ) {
        $result->{result} = '正解だ！';
    }
    else {
        $result->{result} = '間違いだ！';
    }

    # 次の問題
    my $question_id = $question_row->id;
    $question_id += 1;
    $result->{next_question_id} = $question_id;
    $result->{collected_url}    = '/hackerz/question';
    if ( my $collected = $answer_row->fetch_collected ) {
        $result->{collected} = $collected->get_columns;
        $result->{collected_url} .= '/collected/' . $collected->id;
    }
    return $result;
}

1;
