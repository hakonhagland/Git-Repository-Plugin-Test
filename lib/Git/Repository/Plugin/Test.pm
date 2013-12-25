package Git::Repository::Plugin::Test;
use base 'Git::Repository::Plugin';
use base 'Test::Builder::Module';

sub _keywords { qw( run_exit_ok run_exit_is ) }

sub run_exit_ok {
    my $repo = shift;
    return _run_exit($repo, 0, @_);
}

sub run_exit_is {
    return _run_exit(@_);
}

sub _run_exit {
    my $repo = shift;
    my $expected_exit = shift;
    my ($cmd, $opt) = _split_args(@_);

    $opt->{quiet} = !$ENV{TEST_VERBOSE};

    my $out = eval { $repo->run(@$cmd, $opt) };
    my $exit = $? >> 8;

    my $test_name = sprintf('`%s` should exit %d',
        join(' ', 'git', @$cmd), $expected_exit);

    my $tb = __PACKAGE__->builder;

    $tb->level(2);
    my $rv = $tb->is_num($exit, $expected_exit, $test_name);

    if ($out && (!$rv || $ENV{TEST_VERBOSE})) {
        $tb->diag($out);
    }

    return $rv;
}

sub _split_args {
    # split the cmd and options like Git::Repository::Command::new does
    my @args = @_;
    my @o;
    my @cmd = grep { !( ref eq 'HASH' ? push @o, $_ : 0 ) } @args;
    Carp::croak "Too many option hashes given: @o" if @o > 1;
    return (\@cmd, (shift @o || {}));
}

1;

__END__

=pod

=head1 NAME

Git::Repository::Plugin::Test - Test exit of Git commands

=head1 SYNOPSIS

    use Test::More tests => 2;
    use Git::Repository qw(Test);

    my $work_tree = File::Temp->newdir();
    Git::Repository->run(init => $work_tree);
    my $repo = Git::Repository->new(work_tree => $work_tree);

    # run Git commands as tests
    $repo->run_exit_ok('status');
    $repo->run_exit_is(1, 'nonexistant-subcommand');

=head1 DESCRIPTION

Adds C<run_exit_ok> and C<run_exit_is> methods to the Git::Repository object
that can be used for testing Git operations.

=head1 METHODS

L<Git::Repository::Plugin::Test|Git::Repository::Plugin::Test> adds the
following methods:

=head2 run_exit_ok(@cmd)

Like L<Git::Repository|Git::Repository>'s C<run> but exceptions are caught and
reported as test failures.

=head2 run_exit_is($expected_exit_code, @cmd)

Like L<Git::Repository|Git::Repository>'s C<run> but exceptions are caught and
reported as test failures unless exit code matches expected exit code.

=head1 SEE ALSO

L<Git::Repository|Git::Repository>, L<Test::Builder|Test::Builder>

=head1 AUTHOR

Nathaniel G. Nutter <nnutter@cpan.org>

=head1 COPYRIGHT

Copyright 2013 - Nathaniel G. Nutter

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
