SELECT a.contest_id,
		a.hacker_id, 
		a.name, 
		SUM(total_submissions),
		SUM(total_accepted_submissions),
		sum(total_views),
		sum(total_unique_views)
FROM Contests a 
	JOIN Colleges b
    on a.contest_id = b.contest_id
	JOIN Challenges c
    on b.college_id = c.college_id
	LEFT JOIN 
    (Select challenge_id, sum(total_views) as total_views, sum(total_unique_views) as total_unique_views
        FROM View_Stats 
        GROUP BY challenge_id) d
    on c.challenge_id = d.challenge_id
	LEFT JOIN (SELECT challenge_id, sum(total_submissions) as total_submissions, sum(total_accepted_submissions) as total_accepted_submissions
           FROM Submission_Stats
           GROUP BY challenge_id) e
    on c.challenge_id = e.challenge_id
GROUP BY a.contest_id, a.hacker_id, a.name
HAVING SUM(total_submissions)>0 OR SUM(total_accepted_submissions)>0 OR sum(total_views)>0 OR sum(total_unique_views) >0
ORDER BY a.contest_id
    