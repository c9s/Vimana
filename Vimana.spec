Name:           Vimana
Version:        2.26
Release:        1%{?dist}
Summary:        Vim script manager
License:        GPL+ or Artistic
Group:          Development/Libraries
URL:            http://search.cpan.org/dist/Vimana/
Source0:        http://www.cpan.org/authors/id/C/CO/CORNELIUS/Vimana-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:      noarch
BuildRequires:  perl(App::CLI) >= 0.08
BuildRequires:  perl(Archive::Extract)
BuildRequires:  perl(Archive::Zip)
BuildRequires:  perl(DateTime)
BuildRequires:  perl(Digest::MD5)
BuildRequires:  perl(Exporter::Lite)
BuildRequires:  perl(ExtUtils::MakeMaker)
BuildRequires:  perl(File::Path) >= 2.07
BuildRequires:  perl(File::Spec)
BuildRequires:  perl(File::Temp)
BuildRequires:  perl(File::Type)
BuildRequires:  perl(Getopt::Long)
BuildRequires:  perl(HTML::Entities)
BuildRequires:  perl(HTTP::Lite)
BuildRequires:  perl(JSON::PP)
BuildRequires:  perl(LWP::Simple)
BuildRequires:  perl(LWP::UserAgent)
BuildRequires:  perl(Mouse)
BuildRequires:  perl(parent)
BuildRequires:  perl(Path::Class)
BuildRequires:  perl(Regexp::Common)
BuildRequires:  perl(Test::More) >= 0.92
BuildRequires:  perl(URI) >= 1.37
BuildRequires:  perl(Web::Scraper)
BuildRequires:  perl(YAML)
#Makefile checks vim version or die
BuildRequires:  vim-enhanced
Requires:  vim-enhanced
Requires:       perl(App::CLI) >= 0.08
Requires:       perl(Archive::Extract)
Requires:       perl(Archive::Zip)
Requires:       perl(DateTime)
Requires:       perl(Digest::MD5)
Requires:       perl(Exporter::Lite)
Requires:       perl(File::Path) >= 2.07
Requires:       perl(File::Spec)
Requires:       perl(File::Temp)
Requires:       perl(File::Type)
Requires:       perl(Getopt::Long)
Requires:       perl(HTML::Entities)
Requires:       perl(HTTP::Lite)
Requires:       perl(JSON::PP)
Requires:       perl(LWP::Simple)
Requires:       perl(LWP::UserAgent)
Requires:       perl(Mouse)
Requires:       perl(parent)
Requires:       perl(Path::Class)
Requires:       perl(Regexp::Common)
Requires:       perl(URI) >= 1.37
Requires:       perl(Web::Scraper)
Requires:       perl(YAML)
Requires:       perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))

%description
Vimana is an easy to use system for searching , installing, and downloading
vim scripts.

%prep
%setup -q

%build
PERL5_CPANPLUS_IS_RUNNING=1 %{__perl} Makefile.PL INSTALLDIRS=vendor
make %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT

make pure_install PERL_INSTALL_ROOT=$RPM_BUILD_ROOT

find $RPM_BUILD_ROOT -type f -name .packlist -exec rm -f {} \;
find $RPM_BUILD_ROOT -depth -type d -exec rmdir {} 2>/dev/null \;

%{_fixperms} $RPM_BUILD_ROOT/*

%check
make test

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%doc Changes README.mkd todo
%{perl_vendorlib}/*
%{_mandir}/man3/*
%{_mandir}/man1/*
%{_bindir}/vimana
%{_bindir}/vim_record

%changelog
* Fri Jan 16 2015 Athos Ribeiro 2.26-1
- Initial Specfile
