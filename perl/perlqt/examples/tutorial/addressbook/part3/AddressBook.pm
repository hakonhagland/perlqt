package AddressBook;

use strict;
use warnings;
use Qt4;

use Qt4::isa qw( Qt4::Widget );
use Qt4::slots
    addContact => [],
    submitContact => [],
    cancel => [],
# [navigation functions]
    next => [],
    previous => [];
# [navigation functions]    

sub NEW
{
    my ($class, $parent) = @_;
    $class->SUPER::NEW($parent);
    my $nameLabel = Qt4::Label(this->tr('Name:'));
    this->{nameLine} = Qt4::LineEdit();
    this->{nameLine}->setReadOnly(1);

    my $addressLabel = Qt4::Label(this->tr('Address:'));
    this->{addressText} = Qt4::TextEdit();
    this->{addressText}->setReadOnly(1);
    
    this->{addButton} = Qt4::PushButton(this->tr('&Add'));
    this->{addButton}->show();
    this->{submitButton} = Qt4::PushButton(this->tr('&Submit'));
    this->{submitButton}->hide();
    this->{cancelButton} = Qt4::PushButton(this->tr('&Cancel'));
    this->{cancelButton}->hide();
# [navigation pushbuttons]
    this->{nextButton} = Qt4::PushButton(this->tr('&Next'));
    this->{nextButton}->setEnabled(0);
    this->{previousButton} = Qt4::PushButton(this->tr('&Previous'));
    this->{previousButton}->setEnabled(0);
# [navigation pushbuttons]

    this->{order} = 0;

    this->connect(this->{addButton}, SIGNAL 'clicked()', this, SLOT 'addContact()');
    this->connect(this->{submitButton}, SIGNAL 'clicked()', this, SLOT 'submitContact()');
    this->connect(this->{cancelButton}, SIGNAL 'clicked()', this, SLOT 'cancel()');
# [connecting navigation signals]    
    this->connect(this->{nextButton}, SIGNAL 'clicked()', this, SLOT 'next()');
    this->connect(this->{previousButton}, SIGNAL 'clicked()', this, SLOT 'previous()');
# [connecting navigation signals]

    my $buttonLayout1 = Qt4::VBoxLayout();
    $buttonLayout1->addWidget(this->{addButton}, Qt4::AlignTop());
    $buttonLayout1->addWidget(this->{submitButton});
    $buttonLayout1->addWidget(this->{cancelButton});
    $buttonLayout1->addStretch();
# [navigation layout]
    my $buttonLayout2 = Qt4::HBoxLayout();
    $buttonLayout2->addWidget(this->{previousButton});
    $buttonLayout2->addWidget(this->{nextButton});
# [ navigation layout]
    my $mainLayout = Qt4::GridLayout();
    $mainLayout->addWidget($nameLabel, 0, 0);
    $mainLayout->addWidget(this->{nameLine}, 0, 1);
    $mainLayout->addWidget($addressLabel, 1, 0, Qt4::AlignTop());
    $mainLayout->addWidget(this->{addressText}, 1, 1);
    $mainLayout->addLayout($buttonLayout1, 1, 2);
# [adding navigation layout]
    $mainLayout->addLayout($buttonLayout2, 3, 1);
# [adding navigation layout]
    this->setLayout($mainLayout);
    this->setWindowTitle(this->tr('Simple Address Book'));
}

sub addContact
{
    this->{oldName} = this->{nameLine}->text();
    this->{oldAddress} = this->{addressText}->toPlainText();

    this->{nameLine}->clear();
    this->{addressText}->clear();

    this->{nameLine}->setReadOnly(0);
    this->{nameLine}->setFocus(Qt4::OtherFocusReason());
    this->{addressText}->setReadOnly(0);
    
    this->{addButton}->setEnabled(0);
# [disabling navigation]
    this->{nextButton}->setEnabled(0);
    this->{previousButton}->setEnabled(0);
# [disabling navigation]
    this->{submitButton}->show();
    this->{cancelButton}->show();
}

sub submitContact
{
    my $name = this->{nameLine}->text();
    my $address = this->{addressText}->toPlainText();
    
    if ($name eq '' || $address eq '') {
        Qt4::MessageBox::information(this, this->tr('Empty Field'),
            this->tr('Please enter a name and address.'));
    }

    if (!defined this->{contacts}->{$name}) {
        this->{contacts}->{$name}->{address} = $address;
        this->{contacts}->{$name}->{order} = this->{order};
        ++this->{order};
        Qt4::MessageBox::information(this, this->tr('Add Successful'),
            sprintf this->tr('\'%s\' has been added to your address book.'), $name);
    } else {
        Qt4::MessageBox::information(this, this->tr('Add Unsuccessful'),
            sprintf this->tr('Sorry, \'%s\' is already in your address book.'), $name);
    }

    if (scalar keys %{this->{contacts}} == 0) {
        this->{nameLine}->clear();
        this->{addressText}->clear();
    }

    this->{nameLine}->setReadOnly(1);
    this->{addressText}->setReadOnly(1);
    this->{addButton}->setEnabled(1);

# [enabling navigation]
    my $number = scalar keys %{this->{contacts}};
    this->{nextButton}->setEnabled($number > 1);
    this->{previousButton}->setEnabled($number > 1);
# [enabling navigation]
    this->{submitButton}->hide();
    this->{cancelButton}->hide();
}

sub cancel
{
    this->{nameLine}->setText(this->{oldName});
    this->{addressText}->setText(this->{oldAddress});
   
    if (scalar keys %{this->{contacts}} == 0) {
        this->{nameLine}->clear();
        this->{addressText}->clear();
    }
    
    this->{nameLine}->setReadOnly(1);
    this->{addressText}->setReadOnly(1);
    this->{addButton}->setEnabled(1);
    
    my $number = scalar keys %{this->{contacts}};
    this->{nextButton}->setEnabled($number > 1);
    this->{previousButton}->setEnabled($number > 1);
    
    this->{submitButton}->hide();
    this->{cancelButton}->hide();
}

# [next() function]
sub next
{
    my $name = this->{nameLine}->text();
    my $i = this->{contacts}->{$name}->{order};

    if ($i != scalar( keys %{this->{contacts}} )-1) {
        $i++;
    }
    else {
        $i = 0;
    }

    my ($newName) = grep { this->{contacts}->{$_}->{order} == $i } keys %{this->{contacts}};
    this->{nameLine}->setText($newName);
    this->{addressText}->setText(this->{contacts}->{$newName}->{address});
}
# [next() function]
# [previous() function]
sub previous
{
    my $name = this->{nameLine}->text();
    my $i = this->{contacts}->{$name}->{order};

    if ($i == 0) {
        $i = scalar( keys %{this->{contacts}} )-1;
    }
    else {
        $i--;
    }

    my ($newName) = grep { this->{contacts}->{$_}->{order} == $i } keys %{this->{contacts}};
    this->{nameLine}->setText($newName);
    this->{addressText}->setText(this->{contacts}->{$newName}->{address});
}
# [previous() function]

1;
