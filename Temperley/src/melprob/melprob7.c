/* This program infers the key of a melody and also judges the probability of the melody. As input, it takes a
   "notelist" - a series of statements of the form "Note [ontime] [offtime] [pitch]", with ontime and offtime 
   in milliseconds and pitch in integer notation, middle C = 60. (Actually, the program ignores the timing 
   information. It assumes that the notes are listed in chronological order.)

   Compile it like this: "cc -lm melprob7.c -o melprob7". Run it like this: "./melprob7 [input-file]"

   The flag "-v" can be used to control the output. With -v = 0, it outputs the key. With -v = -1, it outputs 
   the total probability of the melody. With -v = -2, it outputs the conditional probability of the last note 
   given the previous notes. The flag "-p" can be used to specify parameter sets (discussed below). For example,
   one could type "./melprob7 -v 0 -p 1 [input-file]".

   For more information on the workings of the program, see _Music and Probability_ chapter 4.

   Some parameters used in the program:

   key profiles
   central pitch profile (mean, variance)
   range profile (variance)
   proximity profile (variance)
   P of a major key vs. a minor key
   P of the tonic on the last note

   A global variable "param_set" controls different values of these. param_set = 1 is parameters gathered from the
   Essen corpus; param_set = 2 is parameters optimized for the Cuddy/Lunney expectation data. (param_set = 0 is old
   parameters gathered from the Essen corpus.) (P of major vs. minor is actually the same for all parameter sets.)

   Other things that I've played around with:

   1. Are the adjusted profiles normalized, i.e. divided by the mass? (Normally yes)
   2. Does the minor key profile have the Essen values or the adjusted "harmonic minor" values? (Normally the former)

*/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

FILE * in_file;
char line[50];
char noteword[10];

struct {
    int ontime;
    int offtime;
    int pitch;
    int pc;
} note[5000];

int numnotes;

/* Profiles generated from Essen collection (minus test corpus) */
double major_key_profile[] =  {0.184,  0.001,  0.155,  0.003,  0.191,  0.109,  0.005,  0.214,  0.001,  0.078,  0.004,  0.055};
double minor_key_profile[] =  {0.192,  0.005,  0.149,  0.179,  0.002,  0.144,  0.002,  0.201,  0.038,  0.012,  0.053,  0.022};

//The Essen minor profile, but with the values for n7 and 7 theoretically adjusted:
//double minor_key_profile[] =  {0.192,  0.005,  0.149,  0.179,  0.002,  0.144,  0.002,  0.201,  0.038,  0.012,  0.015,  0.060};

/* Krumhansl-Kessler profiles */
//double major_key_profile[] = {6.35, 2.23, 3.48, 2.33, 4.38, 4.09, 2.52, 5.19, 2.39, 3.66, 2.29, 2.88};
//double minor_key_profile[] = {6.33, 2.68, 3.52, 5.38, 2.60, 3.53, 2.54, 4.75, 3.98, 2.69, 3.34, 3.17};

/* Kostka-Payne profiles (counting every event) */
//double major_key_profile[12] =  {0.225, 0.007, 0.102, 0.018, 0.151, 0.107, 0.018, 0.192, 0.024, 0.072, 0.009, 0.073};
//double minor_key_profile[12] =  {0.213, 0.019, 0.087, 0.145, 0.008, 0.088, 0.020, 0.238, 0.081, 0.014, 0.022, 0.066};

double proximity_profile[100];
double range_profile[100];
double mean_profile[100];
double adjusted_profile[100];

int param_set; /* 0 = Essen params; 1 = second version of Essen params; 2 = optimal Cuddy/Lunney params */

int abs(int x) {
    if(x>=0) return x;
    else return 0-x;
}

/* If 0, print key name; if -1, print P of melody; if 1, print more info */
int verbosity;

main(argc, argv) 
     int argc;
     char *argv[];
{

    int a, i, n=0, first_time;
    double var;

    param_set = 1;
    verbosity=-1;

    in_file = stdin;

    for(i=1; i<argc; i++) {
	if(strcmp(argv[i], "-v")==0) {
	    sscanf(argv[i+1], "%d", &verbosity);
	    i++;
	}
	else if(strcmp(argv[i], "-p")==0) {
	    sscanf(argv[i+1], "%d", &param_set);
	    i++;
	}
	else {
	    in_file = fopen(argv[i], "r"); 
	    if(in_file == NULL) {printf("Input file not found\n"); exit(1);}
	}
    }

    while (fgets(line, sizeof(line), in_file) !=NULL) {            
	(void) sscanf (line, "%s", noteword);
	if(line[0] == '\0' || line[0] == '\n') continue;
	if (strcmp (noteword, "Note") == 0) { 
	    (void) sscanf (line, "%s %d %d %d", noteword, &note[n].ontime, &note[n].offtime, &note[n].pitch);
	    note[n].pc = note[n].pitch % 12;
	    n++;
	}
    }

    numnotes = n;

    /* Adjust note list to start at time 0 */
    if(note[0].ontime != 0) {
	first_time = note[0].ontime;
	for(n=0; n<numnotes; n++) {
	    note[n].ontime -= first_time;
	    note[n].offtime -= first_time;
	}
    }

    if(verbosity>0) {
	for(n=0; n<numnotes; n++) {
	    printf("Note %d %d %d\n", note[n].ontime, note[n].offtime, note[n].pitch);
	}
    }

    /* Make central pitch profile (mean_profile) */

    if(param_set == 0 || param_set == 1) var = 13.2; /* From Essen data */
    else var = 40.0;

    for(i=0; i<100; i++) {
	mean_profile[i] = (exp( -pow( ((double)(i)-50.0), 2.0) / (2.0 * var))) / (2.51 * sqrt(var));
	/* f(x), where x is the distance from middle G: f(0) = 1.0; f(1) = e ^ -(0.05 ^ 2); f(20) = e ^ -1 = .4; f(40) = e ^ -(2 ^ 2) = .02 */
    }

    /* Make range profile */
    if(param_set == 0) var = 10.544; /* From Essen data */
    else if(param_set == 1) var = 29.0;
    else if(param_set == 2) var = 16.0;

    for(i=0; i<100; i++) {
	range_profile[i] = (exp( -pow( ((double)(i)-50.0), 2.0) / (2.0 * var))) / (2.51 * sqrt(var));
	// Use this line to make a flat range profile
	//range_profile[i] = 0.1;
    }

    /* Make proximity profile */
    if(param_set == 0) var = 8.688; /* From Essen data */
    else if(param_set == 1) var = 7.2;
    else if(param_set == 2) var = 25.0;

    for(i=0; i<100; i++) {
	proximity_profile[i] = (exp( -pow( ((double)(i)-50.0), 2.0) / (2.0 * var))) / (2.51 * sqrt(var));
	// Use this line to make a flat proximity profile
	//proximity_profile[i] = 0.1;
    }

    /* Adjust key profiles by raising them to an exponent? (If the exponent is 1.0, this has no effect) */
    for(i=0; i<12; i++) {
	major_key_profile[i] = pow(major_key_profile[i], 1.0);
	minor_key_profile[i] = pow(minor_key_profile[i], 1.0);
    } 

    if(verbosity>1) {
	printf("Proximity profile:\n");
	for(i=40; i<=60; i++) printf("%6.3f ", proximity_profile[i]);
	printf("\n");
	printf("Range profile:\n");
	for(i=30; i<=60; i++) printf("%6.3f ", range_profile[i]);
	printf("\n");
    }

    analyze_melody();

}

make_adjusted_profile(int n, int mean_p, int prev_p, int k) {

    int i, interval, range_position, start_position, j;
    double raw_profile[100];
    double mass=0.0;

    for(i=0; i<100; i++) {
	interval = i-prev_p;
	if(interval < -50) interval = -50;
	if(interval > 49) interval = 49;
	range_position = i - mean_p;
	if(range_position < -50) range_position = -50;
	if(range_position > 49) range_position = 49;
	start_position = i-65;
	if(start_position < -50) start_position = -50;
	if(start_position > 49) start_position = 49;

	if(prev_p == -1) {
	    if(k<12) raw_profile[i] = major_key_profile[((i+24)-k)%12] * range_profile[range_position+50];
	    else raw_profile[i] = minor_key_profile[((i+24)-k)%12] * range_profile[range_position+50];
	}

	else {
	    if(k<12) raw_profile[i] = major_key_profile[((i+24)-k)%12] * proximity_profile[interval+50] 
			 * range_profile[range_position+50];
	    else raw_profile[i] = minor_key_profile[((i+24)-k)%12] * proximity_profile[interval+50]
		     * range_profile[range_position+50];
	}

	/* Boost the tonic if it's the last note - for both major and minor keys */
	if(param_set == 2) {
	    if(n == numnotes-1 && i % 12 == k % 12) raw_profile[i] *= 20.0;
	}

	mass += raw_profile[i];
    }

    //printf("mass = %6.20f\n", mass);

    /* Now normalize the profile values to sum to 1 */
    for(i=0; i<100; i++) {
	adjusted_profile[i] = raw_profile[i] / mass;
	//adjusted_profile[i] = raw_profile[i] * 1000.0; /* Some adjustment here is necessary, otherwise the numbers get too small. */
    }

    /*
    if(verbosity>1) {
	printf("Pitch:      ");
	for(i=60; i<=72; i++) printf("%6d ", i);
	printf("\nKey profile:");
	for(i=60; i<=72; i++) {
	    if(k<12) printf("%6.3f ", major_key_profile[((i+24)-k)%12]);
	    else printf("%6.3f ", minor_key_profile[((i+24)-k)%12]);
	}	

	printf("\nProximity:  ");
	for(i=60; i<=72; i++) printf("%6.3f ", proximity_profile[(i-prev_p) + 50]);
	printf("\nRange:      ");
	for(i=60; i<=72; i++) printf("%6.3f ", range_profile[(i-mean_p) + 50]);
	printf("\nRaw:        ");
	for(i=60; i<=72; i++) printf("%6.3f ", raw_profile[i]);
	printf("\nAdjusted:   ");
	for(i=60; i<=72; i++) printf("%6.3f ", adjusted_profile[i]);
	printf("\n");
    }
    */
}

analyze_melody() {

    int k, n, i, prev_p, best, total, m;
    int observed_mean, mean_bottom, mean_top;
    double mp, best_score, last_note_prob;
    double key_score[24];
    double analysis_score[24][25];
    double total_score[1000];

    total = 0;
    for(n=0; n<numnotes; n++) total += note[n].pitch;
    mp = (double)total / (double)(numnotes);
    if(mp - (int)mp > 0.5) observed_mean = (int)mp+1;
    else observed_mean = (int)mp;

    mean_top = observed_mean + 12;
    mean_bottom = observed_mean - 12;

    /* Now the "mean" variable corresponds to a range of 12 on either side of the observed mean.
       So analysis_score[k][0] means 12 below the observed mean, etc... */

    //printf("mp = %6.3f, observed_mean = %d, mean bottom = %d, mean top = %d\n", mp, observed_mean, mean_bottom, mean_top);

    /* Set initial analysis scores for each key - higher for major keys */
    for(k=0; k<24; k++) {
	key_score[k] = 0.0;
	for(m=mean_bottom; m<=mean_top; m++) {

	    //analysis_score[k][m+12-observed_mean] = .0833 * .5;
	    //if(k < 12) analysis_score[k][m+12-observed_mean] = .0833 * .75;
	    //else analysis_score[k][m+12-observed_mean] = .0833 * .25;

	    /* Here we set higher prior P for major keys - all param sets use these values */
	    if(k < 12) analysis_score[k][m+12-observed_mean] = .0833 * .88;
	    else analysis_score[k][m+12-observed_mean] = .0833 * .12;
	    
	    /* This (below) is where we set the mean of the central pitch profile - assumed here to be 68 */
	    analysis_score[k][m+12-observed_mean] *= mean_profile[m+50-68]; 

	    //if(m==observed_mean) analysis_score[k][m+12-observed_mean] *= mean_profile[m+50-60];
	    //else analysis_score[k][m+12-observed_mean] = 0.0;
	}
    }

    for(n=0; n<numnotes; n++) total_score[n] = 0.0;

    /* Cycle through the notes. We build up 24 analysis scores for each key - at each note, add the
       score for the current note given key k on to the appropriate key analysis. Also, at each note,
       calculate a total_score - the sum of all key analyses at that point, representing p(surface)
       for the melody so far. */

    prev_p = -1;
    for(n=0; n<numnotes; n++) {

	for(k=0; k<24; k++) {

	    for(m=mean_bottom; m<=mean_top; m++) {
		make_adjusted_profile(n, m, prev_p, k);
		if(m+12-observed_mean < 0 || m+12-observed_mean > 24) {printf("Oops!\n"); exit(1);}
		analysis_score[k][m+12-observed_mean] *= adjusted_profile[note[n].pitch];
		total_score[n] += analysis_score[k][m+12-observed_mean];
	    }
	}

	prev_p = note[n].pitch;

    }

    /* The key analyses now represent the entire melody. Find the best one. */

    best_score = -1000000.0;
    for(k=0; k<24; k++) {
	key_score[k] = 0.0;
	for(m=mean_bottom; m<=mean_top; m++) key_score[k] += analysis_score[k][m+12-observed_mean];
	if(log(key_score[k]) > best_score) {
	    best=k;
	    best_score = log(key_score[k]);
	}
    }

    for(m=mean_bottom; m<=mean_top; m++) {
	//printf("log(P) of melody given key 0 and mean of %d = %6.3f\n", m, log(analysis_score[0][m+12-observed_mean]));
    }

    for(k=0; k<24; k++) {
	if(verbosity>0) printf("For key %d, analysis score = %6.30f; log = %6.3f\n\n", k, key_score[k], log(key_score[k]));
    }

    last_note_prob = total_score[numnotes - 1] / total_score[numnotes - 2];

    if(verbosity>0) printf("best key = %d; best key score = %6.3f; p(surface) = %6.30f; log(p(surface[n-1])) = %6.3f; log(p(surface[n])) = %6.3f; log(last_note_prob) = %6.3f\n", best, best_score, total_score[numnotes-1], log(total_score[numnotes-1]), log(total_score[numnotes-2]), log(last_note_prob)); 

    /* Output key */
    if(verbosity==0) print_keyname(best);

    /* Output total log probability of melody */
    if(verbosity==-1) printf("%6.3f\n", log(total_score[numnotes-1]));

    /* Output P of last note given previous notes  */
    //if(verbosity==-2) printf("%6.8f\n", last_note_prob);

    /* Output log(P) of last note given previous notes  */
    if(verbosity==-2) printf("%6.3f\n", log(last_note_prob));

    /* Output log(P) of last note given previous notes (linear function thereof - used to make charts) */
    //if(verbosity==-2) printf("%6.3f\n", ((log(last_note_prob) * 0.4) + 6.3));

    /* Output linear function of log probability - should not change results in terms of correlation values */
    //printf("%6.3f\n", ((log(total_score[numnotes-1]) + 20.0) * 0.35));

    /* Output joint probability of melody with best key analysis - this is already a logarithm */
    //printf("%6.3f\n", best_score);
    /* Output plain probability of melody */
    //printf("%6.10f\n", total_score[numnotes-1]);
}
	    
print_keyname(int key) {

    switch(key) {
    case 0: printf("C\n"); break;
    case 1: printf("C#\n"); break;
    case 2: printf("D\n"); break;
    case 3: printf("Eb\n"); break;
    case 4: printf("E\n"); break;
    case 5: printf("F\n"); break;
    case 6: printf("F#\n"); break;
    case 7: printf("G\n"); break;
    case 8: printf("Ab\n"); break;
    case 9: printf("A\n"); break;
    case 10: printf("Bb\n"); break;
    case 11: printf("B\n"); break;
    case 12: printf("Cm\n"); break;
    case 13: printf("C#m\n"); break;
    case 14: printf("Dm\n"); break;
    case 15: printf("Ebm\n"); break;
    case 16: printf("Em\n"); break;
    case 17: printf("Fm\n"); break;
    case 18: printf("F#m\n"); break;
    case 19: printf("Gm\n"); break;
    case 20: printf("Abm\n"); break;
    case 21: printf("Am\n"); break;
    case 22: printf("Bbm\n"); break;
    case 23: printf("Bm\n"); break;
    }
}	  
