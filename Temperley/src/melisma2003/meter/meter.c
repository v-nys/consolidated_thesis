
 /***************************************************************************/
 /*                                                                         */
 /*       Copyright (C) 2000 Daniel Sleator and David Temperley             */
 /*           See http://www.link.cs.cmu.edu/music-analysis                 */
 /*        for information about commercial use of this system              */
 /*                                                                         */
 /***************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

#include "meter.h"

static int first_beat[N_LEVELS]; //V: in this context, static is approximately the equivalent of Java "private" ("private to this file")
static int min_pip, max_pip; /* these are set by the caller of create_pip_score_arrays() */ //V: meerbepaald: compute_tactus_level. Maar wat *doen* ze eigenlijk?

//V: Check
int quantize(int t) {
	//pip_time wordt ingesteld als parameter
    /* this computes the pip that will contain the given time */
    /* the times should all be positive so this just rounds */
    return ((t + (pip_time/2))/pip_time);
}

//V: Check
int dquantize(double t, int round) {
    /* this computes the pip that will contain the given time */
    /* the times should all be positive so this just rounds */
    /* if round = -1 then round down, if round = 1 round up, if round=0 then do
       regular rounding */
    if (round == -1) return ((t/pip_time));
    if (round == 1) return ((t/pip_time) + .999999);
    return ((t/pip_time) + .5);
}

//V: Pip_note_list struct gives all the notes at a particular pip
//V: Returns (does not set) base score for particular pip...
//V: Not clear yet how this fits in bigger picture.
double base_score(Pip_note_list * pnl, int higher_base) {
    /* this is the score of putting a beat at a time
     * in which these notes started.
     * if higher_base=TRUE then we remove the length factor.
     * 
     * V:
     * using higher_base means evaluating the score in a different way.
     * But when should higher_base be true...?
     */
    
    double average_length; // average length of the notes, in seconds
    double total; //V: not total duration of piece, just sum of duration of all notes
    int n; // number of notes encountered 
    Pip_note_list * xpnl;

    // V: this block calculates sum of durations and average length of notes
    total = 0.0;
    n = 0;
    for (xpnl = pnl; xpnl != NULL; xpnl = xpnl->next) {
	    total += ms_to_sec(xpnl->note->effective_length);
	    n++;
    }
    if (n == 0) return 0.0;
    average_length = total/((double)n);
    
    if (higher_base) average_length = .5;

    return note_factor * ((sqrt(n) * average_length) + note_bonus); //V: note_factor is a settable parameter 
}

void add_chords() {
   /* Davy added this function. The chordpip value of a chord is its quantized time; 
   * Set the chord value of the corresponding pip_array member to 1.
   * This is the value that will get added to the base value if there is
   * a chord change there */
  int chord_pip, i;
  for (i=0; i<N_pips; i++) pip_array[i].chord = 0;  /* probably already 0 */
  for (i=0; i<N_chords; i++) {
      chord_pip=quantize(prechord[i].time);                
      pip_array[chord_pip].chord=1;
      /* printf("chord at pip number %d\n", chord_pip); */
  }
}

//V: Check
void build_pip_array(Note *nl) {
    
    /* Build the pip array from the note list.  This is where the
     * quantization of the notes takes place.
     * Also clears the first_beat[] array.*/
     
    /* V: 
     * Dit zou de vorm number[level][pip] moeten hebben, denk ik.
     * Kan ook omgekeerd zijn...
     * Pips zijn structs, dus zal eerder array van pips zijn met
     * scores op elk niveau ofzo. */
    
    Note * xn;
    int last_time=0, xtime;
    int i, j;
    Pip_note_list *pnl;//V: later nodig om te kunnen alloceren wanneer we notelist doorlopen en noten op juiste pip zetten

    for (j=0; j<N_LEVELS; j++) {
        first_beat[j] = 0; //V: dit is louter initialisatie: één entry per level geeft aan wanneer de eerste beat van dat level valt - in geval thesis sowieso 0 voor hoogste en dus elk level
    }
    
    //V: doorloopt de hele notelist (i.e. van alle noten in het stuk) en zet eindtijd last_time op maximale eindwaarde
    for (xn = nl; xn != NULL; xn = xn->next) {
	    xtime = xn->start + xn->duration;
	    if (last_time < xtime) last_time = xtime;
    }
    
    N_pips = quantize(last_time)+1; /* the pips start at 0 */ //V dus als de laatste tijd op index n komt, zijn er n+1 pips
    pip_array = (Pip *) xalloc(N_pips * sizeof(Pip));
    
    // stel zo in dat elke pip nul noten bevat en GEEN beat is
    for (i=0; i<N_pips; i++) {
	    pip_array[i].pnl = NULL;
	    pip_array[i].nnotes = 0;
	    for (j=0; j<N_LEVELS; j++) {
	        pip_array[i].is_beat[j] = 0; /* turn off all beat marks */
	    }
    }
    
    add_chords();
    
    /* now let's quantize all the notes and put them into the pip array */
    //V: onthoud dat Pip_note_list veeleer een set is van noten die op een bepaald tijdstip moeten klinken
    for (xn = nl; xn != NULL; xn = xn->next) {
	    i = quantize(xn->start);
	    /* This routine takes each note and "quantizes" it (i.e.
	    determines the number of the pip containing it), then
	    then adds the note to the pip of that number. -Davy */
	    /* now add this note to pip list [i] */
	    pnl = (Pip_note_list *) xalloc(sizeof(Pip_note_list));
	    pnl->note = xn;
	    pnl->weight = 1.0;//V: lijkt eigenlijk niet gebruikt te worden
	    pnl->next = pip_array[i].pnl;
	    pip_array[i].pnl = pnl; 
	    pip_array[i].nnotes++;
	    /* This tallies up the number of notes starting on each pip */
    }
    
    /* Ok we've just done the first part of the quantization.  Now
       we apply a very crude system to deal with close notes that happen
       to be rounded to different pips.  Simple walk through the pip array,
       and when a pip has notes, and its precedecessor has notes, move them
       to the predecessor.  This results in no two occupied pips in a row.
       */
    
    for (i=1; i<N_pips; i++) {
	    if (pip_array[i-1].pnl != NULL && pip_array[i].pnl != NULL) move_notes(i-1, i);
    }
    
    for (i=0; i<N_pips; i++) {
	    pip_array[i].base = base_score(pip_array[i].pnl, FALSE) + pip_array[i].chord; /* Here I add the chord value of each pip to its base value */
	    pip_array[i].higher_base = base_score(pip_array[i].pnl, TRUE) + pip_array[i].chord; 
	    pip_array[i].score = NULL;
    }
}

//V: Check
//V: basically just a mechanism for assertion checking
int nscore(x) {
    /* always call the score array with score[nscore(x)] */
    if (x > max_pip || x < min_pip) {
	    fprintf(stderr, "%s: Error: nscore index %d out of range\n", this_program, x);
	    exit(1);
    }
    return x-min_pip;
}

//V: Check
void free_pip_score_arrays(void) {
    int i;
    for (i=0; i<N_pips; i++) {
	    if (pip_array[i].score != NULL) xfree(pip_array[i].score);
	    pip_array[i].score = NULL;
    }
}

//V: Check
void create_pip_score_arrays(int pmin, int pmax) {
	/* This creates a table for the scores. The size of the
     * table depends on the min and max beat lengths
     */
    /*
     * V:
     * Meerbepaald is er al een pip_array variabele, maar deze moet
     * zelf pip structs bevatten. Deze scores worden in de pips zelf
     * opgeslagen in een array. In het geval van maar één mogelijke
     * beat length (nl. 500 msec bij 120 BPM) maakt dit een array van
     * de grootte van 1 double aan in elke pip.
     */
    int i, j;

    free_pip_score_arrays();
    for (i=0; i<N_pips; i++) {
	    pip_array[i].score = (double *) xalloc((pmax-pmin+1) * sizeof(double));
	    for (j=pmin; j<=pmax; j++) {
	        pip_array[i].score[nscore(j)] = 0.0;
	    }
    }
}

/* Here's the plan for dealing with generating all the beat levels.

   First we generate the tactus level.  We do this by running the
   standard algorithm that (1) rewards putting a beat at a time with
   lots of notes or long notes beginning (computed by base_score()), (2)
   penalizes having successive beats that are quite different in length
   (computed by deviation_penalty()), and (3) restricts the length of
   the beats to be in a small range (400 to 1600 ms).

   Now we use two other algorithms, one that takes a level and uses it
   to build a lower level (one with more beats), and one that takes a
   level uses it to compute a higher level.  The two algorithm are different.

   Level Lowering:

      Call the level you've got to work with the "base level".  Call the
      one you're building the "new level".  The new level must use all
      the beats of the base level. The time period of the new level is
      allowed to range from 1/3 of the shortest beat of the base level,
      to 1/2 of the longest beat of the base level.  Subject to these
      constraints, we build the set of beats with the least cost among
      all patterns. (This is all obsolete now actually...)

   Level Raising:

      Here evey beat of the new level must be a beat of the base level.
      The period of the new level is between 2 times the shortest beat
      of the base level and 3 times the longest beat of the base level.
      The beats are chosen to maximize the usual score subject to these
      constraints.  (This is also not quite right any more.)

 */

//V: Check
//V: deviation here refers to difference in length between two beats
double deviation_penalty(int x, int y) {
    /* the penalty associated with having a beat of length x
       followed by a beat of length y.  The times are in ms. */
    int diff;

    diff = x-y;
    if (diff < 0) diff = -diff;

    if (diff <= beat_slop) return 0.0;

    return beat_interval_factor * ms_to_sec(diff-beat_slop);
}


double best_score(int pip, int j, int *kp, int use_higher_base) {
    /* this computes the k which gives the best score in filling in
       the pip at this period.  if pip-j < 0 the *kp field is set to -1 */
    double max, score, base;
    int bestk, k;

    if (use_higher_base) {
        base = pip_array[pip].higher_base;
    } else {
        base = pip_array[pip].base;
    }

    if (pip-j < 0) {
	    /* the case when it's out of range */
	    *kp = -1;
	    return (base * sqrt(ms_to_sec((tactus_min+tactus_max)/2)));
    }

    max = 0.0;
    bestk = -1;

    for (k=min_pip; k<=max_pip; k++) {
	    if (pip-j-k<0) {
	        score = pip_array[pip-j].score[nscore(k)]
	        +base * sqrt(ms_to_sec((j+j)*pip_time)/2);
	    } else {
	        score = pip_array[pip-j].score[nscore(k)]
	        -deviation_penalty(k*pip_time, j*pip_time)
	        +base * sqrt(ms_to_sec((j+k)*pip_time)/2);
	        /* Without the square root factor here the system prefers shorter
	           beat periods.  This seems necessary to get the tactus level right. */
	    }
	    if ((bestk == -1) || max < score) {
	        max = score;
	        bestk = k;
	    }
    }
    *kp = bestk;
    return max;
}

void compute_tactus_scores(void) {
  /* This goes through and finds the best k for each j at each pip (by calling
     "best score") */
    int pip, j, k;//wat is k hier? let overigens op: best_score wordt ook opgeroepen in label_beats
    for (pip=0; pip<N_pips; pip++) {
        for (j=min_pip; j<=max_pip; j++) {
            pip_array[pip].score[nscore(j)] = best_score(pip, j, &k, FALSE);
        }
    }
}

void label_beats(int pip, int j, int level) {
    /* this labels the beats and it also fills in the best_j fields of
       the pip_array (Having chosen the best last beat, this traces it
       back and makes the whole best level explicit) */
    int k;

    while (1) {
	    pip_array[pip].is_beat[level] = 1;
	    pip_array[pip].best_j = j;
	    if (pip-j < 0) {
	        first_beat[level] = pip;
	        /* printf("The first beat at level %d is at pip %d\n", level, pip); */
	        break;
	    }
	    best_score(pip, j, &k, level == HIGHEST_LEVEL);
	    pip -= j;
	    j = k;
    }
}

double evaluate_solution(int level, int compute_beats) {
    /* first we find the best solution in the last max_pips pips
       (...that is, the best solution in an interval at the end of the
       piece of length max_pip - deciding on the final beat of the best
       solution) then follow it back if compute_beats=1

       Only call this once with compute_beats==TRUE per level, because
       there's no mechanism for clearing the is_beat.
       */
    int j, pip;
    int best_j, best_pip;
    double score, best;

    best = 0.0; /* avoid compiler warning */                     /* This locates the best last beat */
    best_j = best_pip = -1;
    for (pip=N_pips - 1; pip>=N_pips - max_pip && pip >= 0; pip--) {
        for (j=min_pip; j<=max_pip; j++) {
            score = pip_array[pip].score[nscore(j)];
            if (best_pip == -1 || best < score) {
                best = score;
                best_j = j;
                best_pip = pip;
            }
        }
    }
    
    if (best_pip == -1) {
        fprintf(stderr, "%s: Error: no scores to look at.\n", this_program);
        exit(1);
    }
    
    if (compute_beats) label_beats(best_pip, best_j, level);
    return best;
}

//V: Check
void print_beats(int level) {
    int pip;
    int last_beat;
    int delta;

    last_beat = -1;
    for (pip=0; pip<N_pips; pip++) {
	    if (pip_array[pip].is_beat[level]) {
	        if (last_beat == -1) {
	        delta = 0;
	        } else {
	        delta = pip_time * (pip-last_beat);
	        }
	        last_beat = pip;
	        printf("Beat at time %5d  (interval = %5d) (cumulative score = %6.3f)\n",
	           pip*pip_time, delta, pip_array[pip].score[nscore(pip_array[pip].best_j)]);
	    }
    }
}

//V: Check
void print_levels(void) {
    /* assuming that you've computed the beats at all levels, this prints
       out all the levels along with some note information */
    int i, pip;
    Pip_note_list *pnl;

    for (pip=0; pip<N_pips; pip++) {
    for (i=0; i<N_LEVELS; i++) {
        if (pip_array[pip].is_beat[i]) break;
    }
    if (i == N_LEVELS) continue;

    /* this pip has at least one beat....I guess could have just
       looked at the highest level.  But this will work even if
       I didn't happen to compute all the levels yet.  */

    printf("Beat: %5d ", pip*pip_time);

    for (i=0; i<N_LEVELS; i++) {
        if (pip_array[pip].is_beat[i]) printf("x "); else printf("  ");     
    }

    printf("   (");
    for (pnl = pip_array[pip].pnl; pnl!=NULL; pnl = pnl->next) {
        printf("%d", pnl->note->pitch);
        if (pnl->next != NULL) printf(" ");
    }
    
    printf(")\n");
    }
}

void compute_tactus_level(void) {
    int first_time, best_min=0, best_max=0, rc;
    double tmin, tmax, val, best_val=0.0;

    tmin = tactus_min; //normaal 500
    tmax = tactus_min * tactus_width; //gaan uit van vaste 500 msec...

    /*
     Wat gebeurt er precies in deze loop? Verschillende mogelijke lengtes voor
     tacti worden toegepast: telkens vermenigvuldiging met tactus_step.
     */
    for (first_time = TRUE; tmax <= tactus_max; tmax *= tactus_step, tmin *= tactus_step, first_time = FALSE) {

        min_pip = dquantize(tmin, 0);//d staat hier voor double: soms ook ints quantizen, niet hier
        max_pip = dquantize(tmax, 0);//0 is vlag om afronding te bepalen: 0 is gewoon afronden

        create_pip_score_arrays(min_pip, max_pip); //gegeven dat tmin en tmax hier gelijk moeten zijn, zou dit niet erg veel werk mogen zijn
        compute_tactus_scores();
        val = evaluate_solution(TACTUS_LEVEL, FALSE); //laatste param zegt of beats moeten worden berekend

        if (verbosity > 1) {
            printf("Trying tactus level range [%5d, %5d].  Score = %8.3f\n", pip_time * min_pip, pip_time * max_pip, val);
        }

        if (first_time || val > best_val) {
            best_val = val;
            best_min = min_pip;
            best_max = max_pip;
        }
    
        free_pip_score_arrays();
    }

    if (first_time) {
        fprintf(stderr, "%s: Can't compute tactus level, cause tactus_max is too small.\n", this_program);
        zlog_fini();
        exit(1);
    }

    min_pip = best_min;
    max_pip = best_max;
    create_pip_score_arrays(min_pip, max_pip);
    compute_tactus_scores();
    evaluate_solution(TACTUS_LEVEL, TRUE);
    free_pip_score_arrays();
}
