package t::Util;
use Mojo::Base -base;
use Test::More;
use Test::Mojo;
use Mojo::Util qw{dumper};
use TrainingHackerzlab::DB;

sub init {
    my $self = shift;
    $ENV{MOJO_MODE} = 'testing';
    my $t = Test::Mojo->new('TrainingHackerzlab');
    die 'not testing mode' if $t->app->mode ne 'testing';

    # test DB
    $t->app->commands->run( 'generatemore', 'sqlitedb' );
    $t->app->helper(
        test_db => sub {
            TrainingHackerzlab::DB->new( +{ conf => $t->app->config } );
        }
    );
    return $t;
}

# ログインする
sub login {
    my $self    = shift;
    my $t       = shift;
    my $user_id = shift || 1;

    my $user = $t->app->test_db->teng->single( 'user', +{ id => $user_id } );
    my $login_id = $user->login_id;
    my $password = $user->password;
    my $master   = $t->app->test_db->master;
    my $msg      = $master->auth->to_word('IS_LOGIN');

    # セッション確認
    my $session_id = $t->app->build_controller( $t->tx )->session('user');
    is( $session_id, undef, 'session_id' );

    # ログイン画面
    $t->get_ok('/auth')->status_is(200);
    my $dom        = $t->tx->res->dom;
    my $form       = 'form[name=form_login]';
    my $action_url = $dom->at($form)->attr('action');

    # 値を入力
    $dom->at('input[name=login_id]')->attr( +{ value => $login_id } );
    $dom->at('input[name=password]')->attr( +{ value => $password } );

    # input val 取得
    my $params = $self->get_input_val( $dom, $form );

    # ログイン実行
    $t->post_ok( $action_url => form => $params )->status_is(302);
    my $location_url = $t->tx->res->headers->location;
    $t->get_ok($location_url)->status_is(200);

    # 成功画面
    $t->content_like(qr{\Q<b>$msg</b>\E});

    # セッション確認
    $session_id = $t->app->build_controller( $t->tx )->session('user');
    ok( $session_id, 'session_id' );
    return;
}

# ログアウトする
sub logout {
    my $self = shift;
    my $t    = shift;

    # ログアウトボタンの存在する画面
    $t->get_ok('/hackerz/menu')->status_is(200);
    my $dom        = $t->tx->res->dom;
    my $form       = 'form[name=form_logout]';
    my $action_url = $dom->at($form)->attr('action');
    my $master     = $t->app->test_db->master;

    # ログアウト実行
    $t->post_ok($action_url)->status_is(302);
    my $location_url = $t->tx->res->headers->location;
    $t->get_ok($location_url)->status_is(200);

    # 成功画面
    my $msg = $master->auth->to_word('IS_LOGOUT');
    $t->content_like(qr{\Q<b>$msg</b>\E});

    # 他 button, link
    $t->element_exists("a[href=/]");
    $t->element_exists("a[href=/auth]");

    # セッション確認
    my $session_id = $t->app->build_controller( $t->tx )->session('user');
    is( $session_id, undef, 'session_id' );
    return;
}

# input 入力フォームの値を取得
sub get_input_val {
    my $self = shift;
    my $dom  = shift;
    my $form = shift;

    # input text 取得
    my $text_params = $self->_get_input_text_val( $dom, $form );

    # input radio 取得
    my $radio_params = $self->_get_input_radio_val( $dom, $form );

    # input hidden 取得
    my $hidden_params = $self->_get_input_hidden_val( $dom, $form );

    # textarea 取得
    my $textarea_params = $self->_get_textarea_val( $dom, $form );

    # input password 取得
    my $password_params = $self->_get_input_password_val( $dom, $form );

    my $params = +{
        %{$text_params},     %{$radio_params}, %{$hidden_params},
        %{$textarea_params}, %{$password_params},
    };
    return $params;
}

# dom に値を埋め込み
sub input_val_in_dom {
    my $self = shift;
    my $dom  = shift;
    my $form = shift;
    my $data = shift;

    # input text
    $dom = $self->_text_val_in_dom( $dom, $form, $data );

    # input radio
    $dom = $self->_radio_val_in_dom( $dom, $form, $data );

    # textarea
    $dom = $self->_textarea_val_in_dom( $dom, $form, $data );

    return $dom;
}

# input text 入力フォームの値を取得
sub _get_input_text_val {
    my $self = shift;
    my $dom  = shift;
    my $form = shift;

    my $params = +{};
    for my $e ( $dom->find("$form input[type=text]")->each ) {
        my $name = $e->attr('name');
        next if !$name;
        $params->{$name} = $e->val;
    }
    return $params;
}

# input radio 入力フォームの値を取得
sub _get_input_radio_val {
    my $self = shift;
    my $dom  = shift;
    my $form = shift;

    my $params = +{};
    for my $e ( $dom->find("$form input[type=radio]")->each ) {
        my $name = $e->attr('name');
        next if !$name;
        my $tag = $e->to_string;
        if ( $tag =~ /checked/ ) {
            $params->{$name} = $e->val;
        }
    }
    return $params;
}

# input hidden 入力フォームの値を取得
sub _get_input_hidden_val {
    my $self = shift;
    my $dom  = shift;
    my $form = shift;

    my $params = +{};
    for my $e ( $dom->find("$form input[type=hidden]")->each ) {
        my $name = $e->attr('name');
        next if !$name;
        $params->{$name} = $e->val;
    }
    return $params;
}

# textarea 入力フォームの値を取得
sub _get_textarea_val {
    my $self = shift;
    my $dom  = shift;
    my $form = shift;

    my $params = +{};
    for my $e ( $dom->find("$form textarea")->each ) {
        my $name = $e->attr('name');
        next if !$name;
        $params->{$name} = $e->val;
    }
    return $params;
}

# input password 入力フォームの値を取得
sub _get_input_password_val {
    my $self = shift;
    my $dom  = shift;
    my $form = shift;

    my $params = +{};
    for my $e ( $dom->find("$form input[type=password]")->each ) {
        my $name = $e->attr('name');
        next if !$name;
        $params->{$name} = $e->val;
    }
    return $params;
}

# input text の name を全て取得
sub _get_input_text_names {
    my $self = shift;
    my $dom  = shift;
    my $form = shift;

    my $names;
    for my $e ( $dom->find("$form input[type=text]")->each ) {
        my $name = $e->attr('name');
        next if !$name;
        push @{$names}, $name;
    }
    return $names;
}

# input radio の name を全て取得
sub _get_input_radio_names {
    my $self = shift;
    my $dom  = shift;
    my $form = shift;

    my $names;
    for my $e ( $dom->find("$form input[type=radio]")->each ) {
        my $name = $e->attr('name');
        next if !$name;
        my $tag = $e->to_string;
        if ( $tag =~ /checked/ ) {
            push @{$names}, $name;
        }
    }
    return $names;
}

# textarea の name を全て取得
sub _get_textarea_names {
    my $self = shift;
    my $dom  = shift;
    my $form = shift;

    my $names;
    for my $e ( $dom->find("$form textarea")->each ) {
        my $name = $e->attr('name');
        next if !$name;
        push @{$names}, $name;
    }
    return $names;
}

# input text 値の埋め込み
sub _text_val_in_dom {
    my $self = shift;
    my $dom  = shift;
    my $form = shift;
    my $data = shift;

    my $names = $self->_get_input_text_names( $dom, $form );
    for my $name ( @{$names} ) {
        my $val = $data->{$name};
        $dom->at("$form input[name=$name]")->attr( +{ value => $val } );
    }
    return $dom;
}

# input radio 値の埋め込み
sub _radio_val_in_dom {
    my $self = shift;
    my $dom  = shift;
    my $form = shift;
    my $data = shift;

    my $names = $self->_get_input_radio_names( $dom, $form );

    # checked をはずす
    for my $e ( $dom->find("$form input[type=radio][checked]")->each ) {
        my $name = $e->attr('name');
        next if !$name;
        delete $e->attr->{checked};
    }

    for my $name ( @{$names} ) {
        my $val = $data->{$name};
        $dom->at("$form input[name=$name][value=$val]")
            ->attr( 'checked' => undef );
    }
    return $dom;
}

# textarea 値の埋め込み
sub _textarea_val_in_dom {
    my $self = shift;
    my $dom  = shift;
    my $form = shift;
    my $data = shift;

    my $names = $self->_get_textarea_names( $dom, $form );
    for my $name ( @{$names} ) {
        my $val = $data->{$name};
        $dom->at("$form textarea[name=$name]")->content($val);
    }
    return $dom;
}

1;

__END__
