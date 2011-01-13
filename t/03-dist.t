#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use Test::Fatal;
use lib 't/lib/03';

{
    use_ok('Foo::Conflicts::Good');
    is_deeply(
        [ Foo::Conflicts::Good->calculate_conflicts ],
        [],
        "correct versions for all conflicts",
    );
    is(
        exception { Foo::Conflicts::Good->check_conflicts },
        undef,
        "no conflict error"
    );
    is(Foo::Conflicts::Good->dist, 'Foo', "correct dist");
}

{
    {
        my $warnings;
        local $SIG{__WARN__} = sub { $warnings .= $_[0] };
        use_ok('Foo::Conflicts::Bad');
        is($warnings, <<'EOF', "got correct runtime warnings");
Conflict detected for Foo:
  Foo::Two is version 0.02, but must be greater than version 0.02
Conflict detected for Foo:
  Foo is version 0.02, but must be greater than version 0.03
EOF
    }

    is_deeply(
        [ Foo::Conflicts::Bad->calculate_conflicts ],
        [
            { package => 'Foo',      installed => '0.02', required => '0.03' },
            { package => 'Foo::Two', installed => '0.02', required => '0.02' },
        ],
        "correct versions for all conflicts",
    );
    is(
        exception { Foo::Conflicts::Bad->check_conflicts },
        "Conflicts detected for Foo:\n  Foo is version 0.02, but must be greater than version 0.03\n  Foo::Two is version 0.02, but must be greater than version 0.02\n",
        "correct conflict error"
    );
    is(Foo::Conflicts::Bad->dist, 'Foo', "correct dist");
}

{
    use_ok('Bar::Conflicts::Good');
    is_deeply(
        [ Bar::Conflicts::Good->calculate_conflicts ],
        [],
        "correct versions for all conflicts",
    );
    is(
        exception { Bar::Conflicts::Good->check_conflicts },
        undef,
        "no conflict error"
    );
    is(Bar::Conflicts::Good->dist, 'Bar', "correct dist");
}

{
    {
        my $warnings;
        local $SIG{__WARN__} = sub { $warnings .= $_[0] };
        use_ok('Bar::Conflicts::Bad');
        is($warnings, <<'EOF', "got correct runtime warnings");
Conflict detected for Bar:
  Bar::Two is version 0.02, but must be greater than version 0.02
Conflict detected for Bar:
  Bar::Two is version 0.02, but must be greater than version 0.02
Conflict detected for Bar:
  Bar is version 0.02, but must be greater than version 0.03
EOF
    }

    is_deeply(
        [ Bar::Conflicts::Bad->calculate_conflicts ],
        [
            { package => 'Bar',      installed => '0.02', required => '0.03' },
            { package => 'Bar::Two', installed => '0.02', required => '0.02' },
        ],
        "correct versions for all conflicts",
    );
    is(
        exception { Bar::Conflicts::Bad->check_conflicts },
        "Conflicts detected for Bar:\n  Bar is version 0.02, but must be greater than version 0.03\n  Bar::Two is version 0.02, but must be greater than version 0.02\n",
        "correct conflict error"
    );
    is(Bar::Conflicts::Bad->dist, 'Bar', "correct dist");
}

done_testing;
