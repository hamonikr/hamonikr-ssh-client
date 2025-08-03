package PACi18n;

###############################################################################
# This file is part of Ásbrú Connection Manager
#
# Copyright (C) 2017-2022 Ásbrú Connection Manager team (https://asbru-cm.net)
# Copyright (C) 2010-2016 David Torrejon Vaquerizas
#
# Ásbrú Connection Manager is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Ásbrú Connection Manager is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License version 3
# along with Ásbrú Connection Manager.
# If not, see <http://www.gnu.org/licenses/gpl-3.0.html>.
###############################################################################

use utf8;
binmode STDOUT, ':utf8';
binmode STDERR, ':utf8';

use strict;
use warnings;
use FindBin qw ($RealBin);
use POSIX qw(setlocale LC_ALL LC_MESSAGES);
use Encode qw(decode_utf8);

# Try to load Locale::gettext, fallback if not available
our $GETTEXT_AVAILABLE = 0;
eval {
    require Locale::gettext;
    import Locale::gettext qw(gettext ngettext textdomain bindtextdomain bind_textdomain_codeset);
    $GETTEXT_AVAILABLE = 1;
};

# Export functions
use vars qw(@ISA @EXPORT @EXPORT_OK);
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(__i18n __ni18n init_i18n);

# Global variables
our $TEXTDOMAIN = 'asbru-cm';
our $LOCALE_DIR = -d '/usr/share/locale' ? '/usr/share/locale' : "$RealBin/po";

# Initialize internationalization
sub init_i18n {
    my $locale = shift || '';
    
    # Set locale from environment if not specified
    if (!$locale) {
        $locale = $ENV{LANG} || $ENV{LC_ALL} || $ENV{LC_MESSAGES} || 'en_US.UTF-8';
    }
    
    # Set POSIX locale
    setlocale(LC_ALL, $locale);
    setlocale(LC_MESSAGES, $locale);
    
    if ($GETTEXT_AVAILABLE) {
        # Set up gettext
        textdomain($TEXTDOMAIN);
        bindtextdomain($TEXTDOMAIN, $LOCALE_DIR);
        bind_textdomain_codeset($TEXTDOMAIN, 'UTF-8');
        
        print STDERR "INFO: Internationalization initialized with locale: $locale\n";
        print STDERR "INFO: Using gettext with domain: $TEXTDOMAIN, locale dir: $LOCALE_DIR\n";
    } else {
        print STDERR "WARN: Locale::gettext not available, using fallback translation\n";
    }
    
    return 1;
}

# Translation function (singular)
sub __i18n {
    my $msgid = shift // '';
    return '' unless $msgid;
    
    if ($GETTEXT_AVAILABLE) {
        my $translated = gettext($msgid);
        return decode_utf8($translated) if $translated ne $msgid;
    }
    
    # Fallback: return original string
    return $msgid;
}

# Translation function (plural)
sub __ni18n {
    my ($msgid, $msgid_plural, $n) = @_;
    return '' unless $msgid;
    
    if ($GETTEXT_AVAILABLE) {
        my $translated = ngettext($msgid, $msgid_plural, $n);
        return decode_utf8($translated);
    }
    
    # Fallback: simple plural logic
    return $n == 1 ? $msgid : ($msgid_plural || $msgid);
}

1;