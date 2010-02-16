use Test::More tests => 23;

use strict;
use warnings;
use Qt;

my $app = Qt::Application( \@ARGV );

{
    my $widget = Qt::Widget();
    # Check refcount
    is ( Devel::Peek::SvREFCNT($widget), 1, 'refcount' );
    # Test Qt::String marshalling
    my $wt = 'Qt::String marshalling works!';
    $widget->setWindowTitle( $wt );
    is ( $widget->windowTitle(), $wt, 'Qt::String' );
}

{
    my $widget = Qt::Widget();
    # Test a string that has non-latin characters
    use utf8;
    my $wt = 'ターミナル';
    utf8::upgrade($wt);
    $widget->setWindowTitle( $wt );
    is ( $widget->windowTitle(), $wt, 'Qt::String unicode' );
    no utf8;
}

{
    # Test int marshalling
    my $widget = Qt::Widget();
    my $int = 341;
    $widget->resize( $int, $int );
    is ( $widget->height(), $int, 'int' );

    # Test marshalling to int from enum value
    my $textFormat = Qt::TextCharFormat();
    $textFormat->setFontWeight( Qt::Font::Bold() );
    is ( $textFormat->fontWeight(), ${Qt::Font::Bold()}, 'enum to int' );
}

{
    # Test double marshalling
    my $double = 3/7;
    my $doubleValidator = Qt::DoubleValidator( $double, $double * 2, 5, undef );
    is ( $doubleValidator->bottom(), $double, 'double' );
    is ( $doubleValidator->top(), $double * 2, 'double' );
}

{
    # Test bool marshalling
    my $widget = Qt::Widget();
    my $bool = !$widget->isEnabled();
    $widget->setEnabled( $bool );
    is ( $widget->isEnabled(), $bool, 'bool' );
}

{
    # Test int* marshalling
    my ( $x1, $y1, $w1, $h1, $x2, $y2, $w2, $h2 ) = ( 5, 4, 50, 40 );
    my $rect = Qt::Rect( $x1, $y1, $w1, $h1 );
    $rect->getRect( $x2, $y2, $w2, $h2 );
    ok ( $x1 == $x2 &&
         $y1 == $y2 &&
         $w1 == $w2 &&
         $h1 == $h2,
         'int*' );
}

{
    # Test unsigned int marshalling
    my $label = Qt::Label();
    my $hcenter = ${Qt::AlignHCenter()};
    my $top = ${Qt::AlignTop()};
    $label->setAlignment(Qt::AlignHCenter() | Qt::AlignTop());
    my $alignment = $label->alignment();
    is( $alignment, $hcenter|$top, 'unsigned int' );
}

{
    # Test char and uchar marshalling
    my $char = Qt::Char( Qt::Int(87) );
    is ( $char->toAscii(), 87, 'signed char' );
    $char = Qt::Char( Qt::Uchar('f') );
    is ( $char->toAscii(), ord('f'), 'unsigned char' );
    $char = Qt::Char( 'f', 3 );
    is ( $char->row(), 3, 'unsigned char' );
    is ( $char->cell(), ord('f'), 'unsigned char' );
}

{
    # Test short, ushort, and long marshalling
    my $shortSize = length( pack 'S', 0 );
    my $num = 5;
    my $gotNum = 0;
    my $block = Qt::ByteArray();
    my $stream = Qt::DataStream($block, Qt::IODevice::ReadWrite());
    no warnings qw(void);
    $stream << Qt::Short($num);
    my $streamPos = $stream->device()->pos();
    $stream->device()->seek(0);
    $stream >> Qt::Short($gotNum);
    use warnings;
    is ( $gotNum, $num, 'signed short' );

    $gotNum = 0;
    no warnings qw(void);
    $stream->device()->seek(0);
    $stream << Qt::Ushort($num);
    $stream->device()->seek(0);
    $stream >> Qt::Ushort($gotNum);
    use warnings;
    is ( $gotNum, $num, 'unsigned short' );
    is ( $streamPos, $shortSize, 'long' );
}

{
    # Test some QLists
    my $action1 = Qt::Action( 'foo', undef );
    my $action2 = Qt::Action( 'bar', undef );
    my $action3 = Qt::Action( 'baz', undef );

    # Add some stuff to them...
    $action1->{The} = 'quick';
    $action2->{brown} = 'fox';
    $action3->{jumped} = 'over';

    my $actions = [ $action1, $action2, $action3 ]; 

    my $widget = Qt::Widget();
    $widget->addActions( $actions );

    my $gotactions = $widget->actions();

    is_deeply( $actions, $gotactions, 'marshall_ItemList<>' );
}

{
    # Test ambiguous list call
    my $strings = [ qw( The quick brown fox jumped over the lazy dog ) ];
    my $var = Qt::Variant( $strings );
    my $newStrings = $var->toStringList();
    is_deeply( $strings, $newStrings, 'Ambiguous list resolution' );
}

{
    # Test marshall_ValueListItem ToSV
    Qt::setSignature( 'QKeySequence::QKeySequence( int )' );
    my $shortcut1 = Qt::KeySequence( Qt::Key_Enter() );
    my $shortcut2 = Qt::KeySequence( Qt::Key_Tab() );
    my $shortcuts = [ $shortcut1, $shortcut2 ];
    my $action = Qt::Action( 'Foobar', undef );

    $action->setShortcuts( $shortcuts );
    my $gotshortcuts = $action->shortcuts();

    is_deeply( [ map{ eval "\$shortcuts->[$_] == \$gotshortcuts->[$_]" } (0..$#{$shortcuts}) ],
               [ map{ 1 } (0..$#{$shortcuts}) ],
               'marshall_ValueListItem<> FromSV' );
}

{
    my $tree = Qt::TableView( undef );
    my $model = Qt::DirModel();

    $tree->setModel( $model );
    my $top = $model->index( Qt::Dir::currentPath() );
    $tree->setRootIndex( $top );

    my $selectionModel = $tree->selectionModel();
    my $child0 = $top->child(0,0);
    my $child1 = $top->child(0,1);
    my $child2 = $top->child(0,2);
    my $child3 = $top->child(0,3);
    $selectionModel->select( $child0, Qt::ItemSelectionModel::Select() );
    $selectionModel->select( $child1, Qt::ItemSelectionModel::Select() );
    $selectionModel->select( $child2, Qt::ItemSelectionModel::Select() );
    $selectionModel->select( $child3, Qt::ItemSelectionModel::Select() );

    my $selection = $selectionModel->selection();
    my $indexes = $selection->indexes();

    # Run $indexes->[0] == $child0, which should return '1', for each returned
    # index.
    is_deeply( [ map{ eval "\$indexes->[$_] == \$child$_" } (0..$#{$indexes}) ],
               [ map{ 1 } (0..$#{$indexes}) ],
               'marshall_ValueListItem<> ToSV' );
}

{
    # Test Qt::Object::findChildren
    my $widget = Qt::Widget();
    my $childWidget = Qt::Widget($widget);
    my $childPushButton = Qt::PushButton($childWidget);
    my $children = $widget->findChildren('Qt::Widget');
    is_deeply( $children, [$childWidget, $childPushButton], 'Qt::Object::findChildren' );
    $children = $widget->findChildren('Qt::PushButton');
    is_deeply( $children, [$childPushButton], 'Qt::Object::findChildren' );
}
