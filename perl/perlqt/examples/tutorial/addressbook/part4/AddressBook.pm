package AddressBook;

use strict;
use warnings;
use Qt4;

use Qt4::isa qw( Qt4::Widget );

# [Mode enum]
use constant {
    NavigationMode => 0,
    AddingMode => 1,
    EditingMode => 2 };
# [Mode enum]

use Qt4::slots
    addContact => [],
    submitContact => [],
    cancel => [],
# [edit and remove slots]
    editContact => [],
    removeContact => [],
# [edit and remove slots]
    next => [],
    previous => [];

sub NEW
{
    my ($class, $package) = @_;
    $class->SUPER::NEW($package);
    my $nameLabel = Qt4::Label(this->tr('Name:'));
    this->{nameLine} = Qt4::LineEdit();
    this->{nameLine}->setReadOnly(1);

    my $addressLabel = Qt4::Label(this->tr('Address:'));
    this->{addressText} = Qt4::TextEdit();
    this->{addressText}->setReadOnly(1);

    this->{addButton} = Qt4::PushButton(this->tr('&Add'));
# [edit and remove buttons] 
    this->{editButton} = Qt4::PushButton(this->tr('&Edit'));
    this->{editButton}->setEnabled(0);
    this->{removeButton} = Qt4::PushButton(this->tr('&Remove'));
    this->{removeButton}->setEnabled(0);
# [edit and remove buttons] 
    this->{submitButton} = Qt4::PushButton(this->tr('&Submit'));
    this->{submitButton}->hide();
    this->{cancelButton} = Qt4::PushButton(this->tr('&Cancel'));
    this->{cancelButton}->hide();
    
    this->{nextButton} = Qt4::PushButton(this->tr('&Next'));
    this->{nextButton}->setEnabled(0);
    this->{previousButton} = Qt4::PushButton(this->tr('&Previous'));
    this->{previousButton}->setEnabled(0);

    this->{order} = 0;

    this->connect(this->{addButton}, SIGNAL 'clicked()', this, SLOT 'addContact()');
    this->connect(this->{submitButton}, SIGNAL 'clicked()', this, SLOT 'submitContact()');
# [connecting edit and remove] 
    this->connect(this->{editButton}, SIGNAL 'clicked()', this, SLOT 'editContact()');
    this->connect(this->{removeButton}, SIGNAL 'clicked()', this, SLOT 'removeContact()');
# [connecting edit and remove] 
    this->connect(this->{cancelButton}, SIGNAL 'clicked()', this, SLOT 'cancel()');
    this->connect(this->{nextButton}, SIGNAL 'clicked()', this, SLOT 'next()');
    this->connect(this->{previousButton}, SIGNAL 'clicked()', this, SLOT 'previous()');

    my $buttonLayout1 = Qt4::VBoxLayout();
    $buttonLayout1->addWidget(this->{addButton});
# [adding edit and remove to the layout]     
    $buttonLayout1->addWidget(this->{editButton});
    $buttonLayout1->addWidget(this->{removeButton});
# [adding edit and remove to the layout]         
    $buttonLayout1->addWidget(this->{submitButton});
    $buttonLayout1->addWidget(this->{cancelButton});
    $buttonLayout1->addStretch();

    my $buttonLayout2 = Qt4::HBoxLayout();
    $buttonLayout2->addWidget(this->{previousButton});
    $buttonLayout2->addWidget(this->{nextButton});

    my $mainLayout = Qt4::GridLayout();
    $mainLayout->addWidget($nameLabel, 0, 0);
    $mainLayout->addWidget(this->{nameLine}, 0, 1);
    $mainLayout->addWidget($addressLabel, 1, 0, Qt4::AlignTop());
    $mainLayout->addWidget(this->{addressText}, 1, 1);
    $mainLayout->addLayout($buttonLayout1, 1, 2);
    $mainLayout->addLayout($buttonLayout2, 3, 1);

    this->setLayout($mainLayout);
    this->setWindowTitle(this->tr('Simple Address Book'));
}

sub addContact
{
    this->{oldName} = this->{nameLine}->text();
    this->{oldAddress} = this->{addressText}->toPlainText();

    this->{nameLine}->clear();
    this->{addressText}->clear();

    this->updateInterface(AddingMode);
}
# [editContact() function]
sub editContact
{
    this->{oldName} = this->{nameLine}->text();
    this->{oldAddress} = this->{addressText}->toPlainText();

    this->updateInterface(EditingMode);
}
# [editContact() function]
# [submitContact() function beginning]
sub submitContact
{
# [submitContact() function beginning]
    my $name = this->{nameLine}->text();
    my $address = this->{addressText}->toPlainText();

    if ($name eq '' || $address eq '') {
        Qt4::MessageBox::information(this, this->tr('Empty Field'),
            this->tr('Please enter a name and address.'));
    }
# [submitContact() function part1]
    if (this->{currentMode} == AddingMode) {
        
        if (!defined this->{contacts}->{$name}) {
            this->{contacts}->{$name}->{address} = $address;
            this->{contacts}->{$name}->{order} = this->{order};
            this->{order}++;

            Qt4::MessageBox::information(this, this->tr('Add Successful'),
                sprintf this->tr('\'%s\' has been added to your address book.'), $name);
        } else {
            Qt4::MessageBox::information(this, this->tr('Add Unsuccessful'),
                sprintf this->tr('Sorry, \'%1\' is already in your address book.'), $name);
        }
# [submitContact() function part1]
# [submitContact() function part2]
    } elsif (this->{currentMode} == EditingMode) {
        
        if (this->{oldName} ne $name) {
            if (!defined this->{contacts}->{$name}) {
                Qt4::MessageBox::information(this, this->tr('Edit Successful'),
                    sprintf this->tr('\'%s\' has been edited in your address book.'), this->{oldName});
                this->{contacts}->{$name}->{address} = $address;
            } else {
                Qt4::MessageBox::information(this, this->tr('Edit Unsuccessful'),
                    sprintf this->tr('Sorry, \'%s\' is already in your address book.'), $name);
            }
        } elsif (this->{oldAddress} ne $address) {
            Qt4::MessageBox::information(this, this->tr('Edit Successful'),
                sprintf this->tr('\'%s\' has been edited in your address book.'), $name);
            this->{contacts}->{$name}->{address} = $address; 
        }
    }

    this->updateInterface(NavigationMode);
}
# [submitContact() function part2]

sub cancel
{
    this->{nameLine}->setText(this->{oldName});
    this->{addressText}->setText(this->{oldAddress});
    this->updateInterface(NavigationMode);
}
# [removeContact() function]
sub removeContact
{
    my $name = this->{nameLine}->text();
    my $address = this->{addressText}->toPlainText();

    if (defined this->{contacts}->{$name}) {

        my $button = Qt4::MessageBox::question(this,
            this->tr('Confirm Remove'),
            sprintf( this->tr('Are you sure you want to remove \'%s\'?'), $name ),
            Qt4::MessageBox::Yes() | Qt4::MessageBox::No());

        if ($button == Qt4::MessageBox::Yes()) {
            
            this->previous();
            delete this->{contacts}->{$name};

            Qt4::MessageBox::information(this, this->tr('Remove Successful'),
                sprintf this->tr('\'%s\' has been removed from your address book.'), $name);
        }
    }

    this->updateInterface(NavigationMode);
}
# [removeContact() function]
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

# [update interface() part 1]
sub updateInterface
{
    my ($mode) = @_;
    this->{currentMode} = $mode;

    if ($mode == AddingMode || $mode == EditingMode) {
        this->{nameLine}->setReadOnly(0);
        this->{nameLine}->setFocus(Qt4::OtherFocusReason());
        this->{addressText}->setReadOnly(0);

        this->{addButton}->setEnabled(0);
        this->{editButton}->setEnabled(0);
        this->{removeButton}->setEnabled(0);

        this->{nextButton}->setEnabled(0);
        this->{previousButton}->setEnabled(0);

        this->{submitButton}->show();
        this->{cancelButton}->show();
    }
    elsif ($mode == NavigationMode) {
# [update interface() part 1]
# [update interface() part 2]
        if (scalar keys %{this->{contacts}} == 0) {
            this->{nameLine}->clear();
            this->{addressText}->clear();
        }

        this->{nameLine}->setReadOnly(1);
        this->{addressText}->setReadOnly(1);
        this->{addButton}->setEnabled(1);

        my $number = scalar( keys %{this->{contacts}} )-1;
        this->{editButton}->setEnabled($number >= 1);
        this->{removeButton}->setEnabled($number >= 1);
        this->{nextButton}->setEnabled($number > 1);
        this->{previousButton}->setEnabled($number >1 );

        this->{submitButton}->hide();
        this->{cancelButton}->hide();
    }
}
# [update interface() part 2]

1;
