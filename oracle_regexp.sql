-- -----------------------------------------------------------------------------
-- regexp_like(expression, pattern [, match_paramter])
--      expression:
--          A character expression such as a column or field. It can be a VARCHAR2, CHAR, NVARCHAR2, NCHAR, CLOB or NCLOB data type.
--      pattern:
--          ^       Matches the beginning of a string. If used with a match_parameter of 'm', it matches the start of a line anywhere within expression. 
--          $       Matches the end of a string. If used with a match_parameter of 'm', it matches the end of a line anywhere within expression. 
--          *       Matches zero or more occurrences. 
--          +       Matches one or more occurrences. 
--          ?       Matches zero or one occurrence. 
--          .       Matches any character except NULL. 
--          |       Used like an "OR" to specify more than one alternative. 
--          [ ]     Used to specify a matching list where you are trying to match any one of the characters in the list. 
--          [^ ]    Used to specify a nonmatching list where you are trying to match any character except for the ones in the list. 
--          ( )     Used to group expressions as a subexpression. 
--          {m}     Matches m times. 
--          {m,}    Matches at least m times. 
--          {m,n}   Matches at least m times, but no more than n times. 
--          \n      n is a number between 1 and 9. Matches the nth subexpression found within ( ) before encountering \n. 
--          [..]    Matches one collation element that can be more than one character. 
--          [::]    Matches character classes. 
--          [==]    Matches equivalence classes. 
--          \d      Matches a digit character. 
--          \D      Matches a nondigit character. 
--          \w      Matches a word character. 
--          \W      Matches a nonword character. 
--          \s      Matches a whitespace character. 
--          \S      matches a non-whitespace character. 
--          \A      Matches the beginning of a string or matches at the end of a string before a newline character. 
--          \Z      Matches at the end of a string. 
--          *?      Matches the preceding pattern zero or more occurrences. 
--          +?      Matches the preceding pattern one or more occurrences. 
--          ??      Matches the preceding pattern zero or one occurrence. 
--          {n}?    Matches the preceding pattern n times. 
--          {n,}?   Matches the preceding pattern at least n times. 
--          {n,m}?  Matches the preceding pattern at least n times, but not more than m times.
--      match_parameter:
--          'c'     Perform case-sensitive matching. 
--          'i'     Perform case-insensitive matching. 
--          'n'     Allows the period character (.) to match the newline character. By default, the period is a wildcard. 
--          'm'     expression is assumed to have multiple lines, where ^ is the start of a line and $ is the end of a line, regardless of the position of those characters in expression. By default, expression is assumed to be a single line. 
--          'x'     Whitespace characters are ignored. By default, whitespace characters are matched like any other character. 
-- -----------------------------------------------------------------------------
 
select  *
from    c_persons
where   regexp_like(surname, 'Bube*')
;
