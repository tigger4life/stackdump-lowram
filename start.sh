#!/bin/bash
npm install #installs event-stream. required for parsing huge files in nodejs

echo step1
grep -F 'PostTypeId="1"' Posts.xml | grep -Fv 'AnswerCount="0"' | tee questions.xml | grep -F 'Score="-' | cut -d'"' -f2 > deleteQuestions.ids #removes all questions without answers, writes that to questions.xml. also writes all questions with negative score to deleteQuestions.ids

echo step2
grep -Fv 'Score="-' questions.xml > positiveQuestions.xml #writes all positive questions to positivequestions.xml
rm questions.xml

echo step3
grep -F 'PostTypeId="2"' Posts.xml > answers.xml #writes all answers to answers.xml
mv Posts.xml Posts.xml-old

echo step4
head -n2 Posts.xml-old > header.xml #XML headers required. took me 4 days to figure this out.

echo step5
tail -n1 Posts.xml-old > lastLine.xml

echo step6
node remove-downvoted-answers.js #uses deletequestions.ids and answers.xml, writes all answers to non-negative questions to answersWithoutDeletedQuestions.xml, with the id of the question at the beginning, to make sorting easier.
rm deleteQuestions.ids answers.xml

echo step7
node questions-number-beginning.js #uses positiveQuestions.xml, puts the id of the question at the beginning of the line, to make sorting easier. writes to questionsStartId.xml
rm positiveQuestions.xml

echo step8
cat questionsStartId.xml answersWithoutDeletedQuestions.xml > combinedNotSorted.xml
rm questionsStartId.xml answersWithoutDeletedQuestions.xml

echo step9
mkdir /home/$USERNAME/tmp #creates a tmp dir. add your username
sort -T /home/$USERNAME/tmp --parallel=8 -k 1n -n -o combinedSorted.xml combinedNotSorted.xml #sorts everything in tmp dir. let it do its thing, takes a couple hours.
rm combinedNotSorted.xml

echo step10
cp header.xml  Posts.xml
tail -n +3 combinedSorted.xml >> Posts.xml
rm combinedSorted.xml

echo step11
cat lastLine.xml >> Posts.xml #adds the lastline to the file.
rm lastLine.xml
rm header.xml
rm Posts.xml-old
rm -rf /home/$USERNAME/tmp

echo DONE!
