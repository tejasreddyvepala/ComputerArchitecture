# Tests using Simple Scalar ( Branch predictors and cache )

An architectural simulator mimics how a computer device would behave. Programs on a variety of contemporary processor architectures, including Out-of-Order (OoO) issue processors, that allow non-blocking caches, speculative execution, and cutting-edge branch prediction can be simulated with SimpleScalar. 

## Setup

``` 
make config-pisa
make
```

Run any of the SimpleScalar simulator models on any test that corresponds to the built target to validate the build:

```
./sim-outorder tests-pisa/bin.little/test-math
```

This should publish the output of the test and various simulation statistics. 

The following command is used to adjust the processor's settings (cache latencies, cache configuration, number of functional units, branch predictor, etc.). The parameters to be changed can be supplied through command line options or a configuration file.

```
./sim-outorder -h
```

Using a cross-compiler to create executables for the PISA/Alpha targets is necessary in order to run our own binaries on the simulators. One can cross-compile to executables on appropriate targets (PISA/Alpha) once the cross-compiler has been set up properly. 

Example:

```
bin/sslittle-na-sstrix-gcc -g -O -o mytests/bpred_corr_branch mytests/bpred_corr_branch.c
```

## How to run tests

Run the `run_analysis.sh` bash script to automate the task of running my intended tests on the `sim-outorder} simulator with PISA target after the project has been built with our included tests (by executing my Makefile).

```
Usage: ./run_analysis.sh [ANALYSIS_TYPE] [TEST_FILE_PATH] [DEBUG]
```
- `ANALYSIS_TYPE` can be either 'b' for testing branch predictors or 'c' for doing analysis on algorithms that ignore caches.
- `TEST_FILE_PATH` takes in the path to the executable to run the `sim-outorder` simulator on. Irrelevant when `ANALYSIS_TYPE` == 'c'.
- `DEBUG` alone after '1' produces helpful statistics and messages regarding the active tests.

**Example**:
```
./run_analysis.sh b mytests/bpred_corr_branch 0

Executing analysis on branch predictors

         Running sim-outorder simulator with 2lev-GAg branch predictor...
         Running sim-outorder simulator with 2lev-gshare branch predictor...
         Running sim-outorder simulator with 2lev-PAg branch predictor...
         Running sim-outorder simulator with 2lev-PAp-concat branch predictor...
         Running sim-outorder simulator with 2lev-PAp-xor branch predictor...
         Running sim-outorder simulator with bimod branch predictor...
         Running sim-outorder simulator with comb branch predictor...
         Running sim-outorder simulator with nottaken branch predictor...
         Running sim-outorder simulator with taken branch predictor...

Extracting vital branch prediction results from the simulator runs...

        Saving bpred:2lev-GAg's results...
        Saving bpred:2lev-gshare's results...
        Saving bpred:2lev-PAg's results...
        Saving bpred:2lev-PAp-concat's results...
        Saving bpred:2lev-PAp-xor's results...
        Saving bpred:bimod's results...
        Saving bpred:comb's results...
        Saving bpred:nottaken's results...
        Saving bpred:taken's results...

```

## Experiments

#### Branch Predictors 

A hypothesis we wanted to prove was how dynamic global predictors should outperform dynamic local predictors. Randomness was embedded because only then one can point out the exploitation, by the global predictor, of the auxiliary information about other branch conditionals that global branch history possesses, instead of simply "learning" the pattern itself. This global view lacks in the local predictors ergo their failure in comparison with global predictors. 

For this experiment, we configured various branch predictors . two-level adaptive (and its numerous flavours: GAg, PAg, PAp, gshare), bimodal, hybrid between two-level adaptive and bimodal (named 'comb'), taken, not-taken, etc. Each of these branch predictors were employed sequentially while executing `mytests/bpred_corr_branch.c` which contains the source code for 'executing correlated branch conditionals with random pattern'. Further experiments include modifying parameters of the branch predictor such as history length, table size, etc.  

#### Caches

These are subtly different from Cache-aware algorithms as Michael Bender explains in his brief technical paper, are algorithms written craftily to exploit how caches work and their structure in order to attain superior asymptotic time complexity. As the name suggests, these algorithms are oblivious to the memory heirarchy and ergo are anticipated to work flawlessly even on machines with different cache levels, cache line size, etc. than the machine on which such algorithms were tested on. 

**Configurations**: 
The L1 data cache is of 16KiB (128 sets, 32B block size, 4 associativity) and the L2 data cache is of 256KiB (1024 sets, 64B block size, 4 associativity). Both level caches have 'LRU' as their block replacement policies.

## Results and observations

#### Branch Predictors 

Surprisingly, the results don't come out to be consistent with the hypotesis, which can be seen below. 

```
$ ./run_analysis.sh b mytests/bpred_corr_branch.o 1
> [...]

Extracting vital branch prediction results from the simulator runs...

        Saving bpred:2lev-GAg's results...
        Printing bpred:2lev-GAg's metrics:
                bpred_2lev.bpred_addr_rate    0.8181 # branch address-prediction rate (i.e., addr-hits/updates)
                bpred_2lev.bpred_dir_rate    0.8227 # branch direction-prediction rate (i.e., all-hits/updates)
                bpred_2lev.bpred_jr_rate    0.9534 # JR address-prediction rate (i.e., JR addr-hits/JRs seen)

        Saving bpred:2lev-gshare's results...
        Printing bpred:2lev-gshare's metrics:
                bpred_2lev.bpred_addr_rate    0.9055 # branch address-prediction rate (i.e., addr-hits/updates)
                bpred_2lev.bpred_dir_rate    0.9096 # branch direction-prediction rate (i.e., all-hits/updates)
                bpred_2lev.bpred_jr_rate    0.9598 # JR address-prediction rate (i.e., JR addr-hits/JRs seen)

        Saving bpred:2lev-PAg's results...
        Printing bpred:2lev-PAg's metrics:
                bpred_2lev.bpred_addr_rate    0.9471 # branch address-prediction rate (i.e., addr-hits/updates)
                bpred_2lev.bpred_dir_rate    0.9506 # branch direction-prediction rate (i.e., all-hits/updates)
                bpred_2lev.bpred_jr_rate    0.9652 # JR address-prediction rate (i.e., JR addr-hits/JRs seen)

        Saving bpred:2lev-PAp-concat's results...
        Printing bpred:2lev-PAp-concat's metrics:
                bpred_2lev.bpred_addr_rate    0.9371 # branch address-prediction rate (i.e., addr-hits/updates)
                bpred_2lev.bpred_dir_rate    0.9388 # branch direction-prediction rate (i.e., all-hits/updates)
                bpred_2lev.bpred_jr_rate    0.9850 # JR address-prediction rate (i.e., JR addr-hits/JRs seen)

        Saving bpred:2lev-PAp-xor's results...
        Printing bpred:2lev-PAp-xor's metrics:
                bpred_2lev.bpred_addr_rate    0.9610 # branch address-prediction rate (i.e., addr-hits/updates)
                bpred_2lev.bpred_dir_rate    0.9630 # branch direction-prediction rate (i.e., all-hits/updates)
                bpred_2lev.bpred_jr_rate    0.9818 # JR address-prediction rate (i.e., JR addr-hits/JRs seen)

        Saving bpred:bimod's results...
        Printing bpred:bimod's metrics:
                bpred_bimod.bpred_addr_rate    0.9313 # branch address-prediction rate (i.e., addr-hits/updates)
                bpred_bimod.bpred_dir_rate    0.9357 # branch direction-prediction rate (i.e., all-hits/updates)
                bpred_bimod.bpred_jr_rate    0.9558 # JR address-prediction rate (i.e., JR addr-hits/JRs seen)
        Saving bpred:comb's results...
        Printing bpred:comb's metrics:
                bpred_comb.bpred_addr_rate    0.9621 # branch address-prediction rate (i.e., addr-hits/updates)
                bpred_comb.bpred_dir_rate    0.9651 # branch direction-prediction rate (i.e., all-hits/updates)
                bpred_comb.bpred_jr_rate    0.9705 # JR address-prediction rate (i.e., JR addr-hits/JRs seen)

        Saving bpred:nottaken's results...
        Printing bpred:nottaken's metrics:
                bpred_nottaken.bpred_addr_rate    0.3425 # branch address-prediction rate (i.e., addr-hits/updates)
                bpred_nottaken.bpred_dir_rate    0.3425 # branch direction-prediction rate (i.e., all-hits/updates)
                bpred_nottaken.bpred_jr_rate    0.0000 # JR address-prediction rate (i.e., JR addr-hits/JRs seen)

        Saving bpred:taken's results...
        Printing bpred:taken's metrics:
                bpred_taken.bpred_addr_rate    0.3425 # branch address-prediction rate (i.e., addr-hits/updates)
                bpred_taken.bpred_dir_rate    0.3425 # branch direction-prediction rate (i.e., all-hits/updates)
                bpred_taken.bpred_jr_rate    0.0000 # JR address-prediction rate (i.e., JR addr-hits/JRs seen)             
```            

One would expect the global predictors such as gshare & GAg to produce better direction-prediction rate than the local predictors (PAp, PAg, etc.). I've been debugging the obscruity behind the results and shall update here soon.


#### Caches

```
$ ./run_analysis.sh c . 1
> 

Executing analysis on cache-oblivious algorithms

Extracting vital cache stats from the simulator runs...

        Saving cache_row's results...
        Printing cache:row's metrics:
                sim_elapsed_time                  3 # total simulation time in seconds
                sim_cycle                   5401841 # total simulation time in cycles
                sim_IPC                      1.6233 # instructions per cycle
                dl1.miss_rate                0.1250 # miss rate (i.e., misses/ref)
                ul2.miss_rate                0.3004 # miss rate (i.e., misses/ref)

        Saving cache_col's results...
        Printing cache:col's metrics:
                sim_elapsed_time                  6 # total simulation time in seconds
                sim_cycle                   7897842 # total simulation time in cycles
                sim_IPC                      1.7428 # instructions per cycle
                dl1.miss_rate                0.4162 # miss rate (i.e., misses/ref)
                ul2.miss_rate                0.0793 # miss rate (i.e., misses/ref)
```

- One can notice how the `sim_elapsed_time` & `sim_cycle` for column-major order is more than that of the row-major order traversal, as expected.

- As we speculated, the L1 data cache miss rate (`dl1.miss_rate`) is substantially greater for `cache_col` than `cache_row`.

- `sim_IPC` is a misleading metric here as its more for column-major order than row-major order. I say its misleading because the complete simulation results (`results/result_cache_*`) expresses how `cache_col` runs more total instructions (`sim_total_insn`) than `cache_row` (even though the #load, store & branch instructions are the same) in proportionately lesser time.

- The affects on `sim_elapsed_time` & `sim_IPC` for column-major order w.r.t row-major order can be seen amplified if we decrease the cache hit latencies (`-cache:dl1lat` and `-cache:dl2lat`) and increase the memory access latency (`-mem:lat`) in both the  files. 


## Future Work

- Debug experiments on branch predictors.
- Try row-major order and column-major order traversal for diverse cache configurations.
- Prove row-major order traversal is cache-**oblivious** by experimenting on different memory hierarchies and expecting similar results throughout.  
- Add more cache-oblivious algorithms.
