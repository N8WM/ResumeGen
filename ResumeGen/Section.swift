//
//  Section.swift
//  ResumeGen
//
//  Created by Nathan McCutchen on 5/24/24.
//

import Foundation
import SwiftUI



protocol Compilable {
    func latex() -> String
}

protocol Item: Compilable {
    static var sectionTitle: String { get }
}

protocol DocElement: Compilable {}

struct LocationInPerson {
    var city: String
    var state: String

    func toString() -> String {
        return "\(city), \(state)"
    }
}

enum Location {
    case InPerson(LocationInPerson)
    case Hybrid(LocationInPerson)
    case Remote

    func toString() -> String {
        switch self {
        case .InPerson(let location):
            return location.toString()
        case .Hybrid(let location):
            return "\(location.toString()) (Hybrid)"
        default:
            return "Remote"
        }
    }
}

func formatDate(date: Date) -> String {
    let df = DateFormatter()
    df.dateFormat = "MMM yyyy"
    return df.string(from: date)
}

struct DateRange {
    var start_date: Date
    var end_date: Date

    func toString() -> String {
        return "\(formatDate(date: start_date)) -- \(formatDate(date: end_date))"
    }
}

enum Temporal {
    case Range(DateRange)
    case Moment(Date)

    func toString() -> String {
        switch self {
        case .Range(let range):
            return "\(range.toString())"
        case .Moment(let date):
            return formatDate(date: date)
        }
    }
}

struct Link {
    var url: String
    var displayText: String

    func toString() -> String {
        return "\\href{\(self.url)}{\\underline{\(self.displayText)}}"
    }
}



class Title: DocElement {
    var firstName: String
    var middleInitial: Optional<String>
    var lastName: String
    var phoneNumber: String
    var email: String
    var urls: Array<Link>

    init(firstName: String, middleInitial: Optional<String>, lastName: String, phoneNumber: String, email: String, urls: Array<Link>) {
        self.firstName = firstName
        self.middleInitial = middleInitial
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.email = email
        self.urls = urls
    }

    func latex() -> String {
        var cat = "\\begin{center}\n"
        cat    += "  \\textbf{\\Huge \\scshape \(self.firstName) \(self.middleInitial?.appending(". ") ?? "")\(self.lastName)} \\\\ \\vspace{1pt}\n"
        cat    += "  \\small \(self.phoneNumber) $|$ \\href{mailto:\(self.email)}{\\underline{\(self.email)}}\n"
        var urlList: Array<String> = []
        for url in urls {
            urlList.append("  \(url.toString())")
        }
        cat    += urlList.joined(separator: " $|$\n")
        cat    += "\\end{center}"
        return cat
    }
}



class Section<T: Item>: DocElement {
    var title = T.sectionTitle
    var items: Array<T>

    init() {
        self.items = []
    }

    func addItem(item: T) {
        self.items.append(item)
    }
    
    func latex() -> String {
        switch T.sectionTitle {
        case TechnicalSkillItem.sectionTitle:
            var cat  = "\\section{\(self.title)}\n"
            cat     += "  \\begin{itemize}[leftmargin=0.15in, label={}]\n"
            cat     += "    \\small{\\item{\n"
            for item in self.items {
                cat += "\(item.latex())\n"
            }
            cat     += "    }}\n"
            cat     += "  \\end{itemize}\n"
            return cat
        default:
            var cat  = "\\section{\(self.title)}\n"
            cat     += "  \\resumeSubHeadingListStart\n"
            for item in self.items {
                cat += "\(item.latex())\n"
            }
            cat     += "  \\resumeSubHeadingListEnd\n"
            return cat
        }
    }
}



class EducationItem: Item {
    static let sectionTitle = "Education"

    var school: String
    var location: Location
    var degree: Optional<String>
    var dates: Temporal

    init(school: String, location: Location, degree: String, dates: Temporal) {
        self.school = school
        self.location = location
        self.degree = degree
        self.dates = dates
    }

    func latex() -> String {
        var cat = "    \\resumeSubheading\n"
        cat    += "      {\(self.school)}{\(self.location.toString())}\n"
        cat    += "      {\(self.degree ?? "")}{\(self.dates.toString())}\n"
        return cat
    }
}

class ExperienceItem: Item {
    static let sectionTitle = "Experience"

    var position: String
    var dates: Temporal
    var organization: Optional<String>
    var location: Location
    var bullets: Array<String>

    init(position: String, dates: Temporal, organization: Optional<String>, location: Location, bullets: Array<String>) {
        self.position = position
        self.dates = dates
        self.organization = organization
        self.location = location
        self.bullets = bullets
    }

    func latex() -> String {
        var cat  = "    \\resumeSubheading\n"
        cat     += "      {\(self.position)}{\(self.dates.toString())}\n"
        cat     += "      {\(self.organization ?? "")}{\(self.location.toString())}\n"
        cat     += "      \\resumeItemListStart\n"
        for bullet in self.bullets {
            cat += "        \\resumeItem{\(bullet)}\n"
        }
        cat     += "      \\resumeItemListEnd\n"
        return cat
    }
}

class ProjectItem: Item {
    static let sectionTitle = "Projects"
    
    var title: String
    var keywords: Array<String>
    var dates: Temporal
    var bullets: Array<String>

    init(title: String, keywords: Array<String>, dates: Temporal, bullets: Array<String>) {
        self.title = title
        self.keywords = keywords
        self.dates = dates
        self.bullets = bullets
    }

    func latex() -> String {
        var cat  = "    \\resumeProjectHeading\n"
        cat     += "      {\\textbf{\(self.title)} $|$ \\emph{\(self.keywords.joined(separator: ", "))}}{\(dates.toString())\n"
        cat     += "      \\resumeItemListStart\n"
        for bullet in bullets {
            cat += "        \\resumeItem{\(bullet)}\n"
        }
        cat     += "      \\resumeItemListEnd\n"
        return cat
    }
}

class TechnicalSkillItem: Item {
    static let sectionTitle = "Technical Skills"

    var label: String
    var list: Array<String>

    init(label: String, list: Array<String>) {
        self.label = label
        self.list = list
    }
    
    func latex() -> String {
        return "      \\textbf{\(self.label)}{: \(self.list.joined(separator: ", "))} \\\\\n"
    }
}



let DOC_SETUP = #"""
%-------------------------
% Resume in Latex
% Author : Jake Gutierrez
% Based off of: https://github.com/sb2nov/resume
% License : MIT
%------------------------

\documentclass[letterpaper,11pt]{article}

\usepackage{latexsym}
\usepackage[empty]{fullpage}
\usepackage{titlesec}
\usepackage{marvosym}
\usepackage[usenames,dvipsnames]{color}
\usepackage{verbatim}
\usepackage{enumitem}
\usepackage[hidelinks]{hyperref}
\usepackage{fancyhdr}
\usepackage[english]{babel}
\usepackage{tabularx}
\input{glyphtounicode}


%----------FONT OPTIONS----------
% sans-serif
% \usepackage[sfdefault]{FiraSans}
% \usepackage[sfdefault]{roboto}
% \usepackage[sfdefault]{noto-sans}
% \usepackage[default]{sourcesanspro}

% serif
% \usepackage{CormorantGaramond}
% \usepackage{charter}


\pagestyle{fancy}
\fancyhf{} % clear all header and footer fields
\fancyfoot{}
\renewcommand{\headrulewidth}{0pt}
\renewcommand{\footrulewidth}{0pt}

% Adjust margins
\addtolength{\oddsidemargin}{-0.5in}
\addtolength{\evensidemargin}{-0.5in}
\addtolength{\textwidth}{1in}
\addtolength{\topmargin}{-.5in}
\addtolength{\textheight}{1.0in}

\urlstyle{same}

\raggedbottom
\raggedright
\setlength{\tabcolsep}{0in}

% Sections formatting
\titleformat{\section}{
  \vspace{-4pt}\scshape\raggedright\large
}{}{0em}{}[\color{black}\titlerule \vspace{-5pt}]

% Ensure that generate pdf is machine readable/ATS parsable
\pdfgentounicode=1

%-------------------------
% Custom commands
\newcommand{\resumeItem}[1]{
  \item\small{
    {#1 \vspace{-2pt}}
  }
}

\newcommand{\resumeSubheading}[4]{
  \vspace{-2pt}\item
    \begin{tabular*}{0.97\textwidth}[t]{l@{\extracolsep{\fill}}r}
      \textbf{#1} & #2 \\
      \textit{\small#3} & \textit{\small #4} \\
    \end{tabular*}\vspace{-7pt}
}

\newcommand{\resumeSubSubheading}[2]{
    \item
    \begin{tabular*}{0.97\textwidth}{l@{\extracolsep{\fill}}r}
      \textit{\small#1} & \textit{\small #2} \\
    \end{tabular*}\vspace{-7pt}
}

\newcommand{\resumeProjectHeading}[2]{
    \item
    \begin{tabular*}{0.97\textwidth}{l@{\extracolsep{\fill}}r}
      \small#1 & #2 \\
    \end{tabular*}\vspace{-7pt}
}

\newcommand{\resumeSubItem}[1]{\resumeItem{#1}\vspace{-4pt}}

\renewcommand\labelitemii{$\vcenter{\hbox{\tiny$\bullet$}}$}

\newcommand{\resumeSubHeadingListStart}{\begin{itemize}[leftmargin=0.15in, label={}]}
\newcommand{\resumeSubHeadingListEnd}{\end{itemize}}
\newcommand{\resumeItemListStart}{\begin{itemize}}
\newcommand{\resumeItemListEnd}{\end{itemize}\vspace{-5pt}}

%-------------------------------------------
%%%%%%  RESUME STARTS HERE  %%%%%%%%%%%%%%%%%%%%%%%%%%%%


"""#



class Document: Compilable {
    var contents: Array<DocElement>

    init(contents: Array<DocElement>) {
        self.contents = contents
    }

    func latex() -> String {
        var cat = DOC_SETUP
        cat += "\\begin{document}\n\n"
        for item in contents {
            cat += "\(item.latex())\n\n"
        }
        cat += "\\end{document}"
        return cat
    }
}
