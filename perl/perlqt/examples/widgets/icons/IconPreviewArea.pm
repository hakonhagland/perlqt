package IconPreviewArea;

use strict;
use warnings;
use blib;

use Qt4;
# [0]
use Qt4::isa qw( Qt4::Widget );
use constant { NumModes => 4, NumStates => 2 };

sub icon() {
    return this->{icon};
}

sub size() {
    return this->{size};
}

sub stateLabels() {
    return this->{stateLabels};
}

sub setStateLabels($) {
    return this->{stateLabels} = shift;
}

sub modeLabels() {
    return this->{modeLabels};
}

sub setModeLabels($) {
    return this->{modeLabels} = shift;
}

sub pixmapLabels() {
    return this->{pixmapLabels};
}

sub setPixmapLabels($) {
    return this->{pixmapLabels} = shift;
}
# [0]

# [0]
sub NEW {
    my ( $class, $parent ) = @_;
    $class->SUPER::NEW( $parent );

    my $mainLayout = Qt4::GridLayout();
    this->setLayout($mainLayout);

    this->setStateLabels( [] );
    this->stateLabels->[0] = this->createHeaderLabel(this->tr('Off'));
    this->stateLabels->[1] = this->createHeaderLabel(this->tr('On'));

    this->setModeLabels( [] );
    this->modeLabels->[0] = this->createHeaderLabel(this->tr('Normal'));
    this->modeLabels->[1] = this->createHeaderLabel(this->tr('Active'));
    this->modeLabels->[2] = this->createHeaderLabel(this->tr('Disabled'));
    this->modeLabels->[3] = this->createHeaderLabel(this->tr('Selected'));

    for (my $j = 0; $j < NumStates; ++$j) {
        $mainLayout->addWidget(this->stateLabels->[$j], $j + 1, 0);
    }

    this->setPixmapLabels( [] );
    for (my $i = 0; $i < NumModes; ++$i) {
        $mainLayout->addWidget(this->modeLabels->[$i], 0, $i + 1);

        for (my $j = 0; $j < NumStates; ++$j) {
            this->pixmapLabels->[$i]->[$j] = this->createPixmapLabel();
            $mainLayout->addWidget(this->pixmapLabels->[$i]->[$j], $j + 1, $i + 1);
        }
    }

    this->{size} = Qt4::Size();
}
# [0]

# [1]
sub setIcon {
    my ($icon) = @_;
    this->{icon} = $icon;
    this->updatePixmapLabels();
}
# [1]

# [2]
sub setSize {
    my ($size) = @_;
    if ($size != this->size) {
        this->{size} = $size;
        this->updatePixmapLabels();
    }
}
# [2]

# [3]
sub createHeaderLabel {
    my ($text) = @_;
    my $label = Qt4::Label(sprintf this->tr('<b>%s</b>'), $text);
    $label->setAlignment(Qt4::AlignCenter());
    return $label;
}
# [3]

# [4]
sub createPixmapLabel {
    my $label = Qt4::Label();
    $label->setEnabled(0);
    $label->setAlignment(Qt4::AlignCenter());
    $label->setFrameShape(Qt4::Frame::Box());
    $label->setSizePolicy(Qt4::SizePolicy::Expanding(), Qt4::SizePolicy::Expanding());
    $label->setBackgroundRole(Qt4::Palette::Base());
    $label->setAutoFillBackground(1);
    $label->setMinimumSize(132, 132);
    return $label;
}
# [4]

# [5]
sub updatePixmapLabels {
    for (my $i = 0; $i < NumModes; ++$i) {
        my $mode;
        if ($i == 0) {
            $mode = Qt4::Icon::Normal();
        } elsif ($i == 1) {
            $mode = Qt4::Icon::Active();
        } elsif ($i == 2) {
            $mode = Qt4::Icon::Disabled();
        } else {
            $mode = Qt4::Icon::Selected();
        }

        for (my $j = 0; $j < NumStates; ++$j) {
            my $state = ($j == 0) ? Qt4::Icon::Off() : Qt4::Icon::On();
            my $icon = this->icon;
            if ( $icon ) {
                my $pixmap = $icon->pixmap(this->size, $mode, $state);
                this->pixmapLabels->[$i]->[$j]->setPixmap($pixmap);
                this->pixmapLabels->[$i]->[$j]->setEnabled(!$pixmap->isNull());
            }
        }
    }
}
# [5]

1;
