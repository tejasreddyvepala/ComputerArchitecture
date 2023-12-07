# Tests-on-Simple-Scalar

In the words of the creators, *"The SimpleScalar tool set is a system software infrastructure used to build modeling applications for program performance analysis, detailed microarchitectural modeling, and hardware-software co-verification"*. An architectural simulator reproduces the behaviour of a computing device. With SimpleScalar, one can simulate programs on various configurations of modern processors, even Out-of-Order (OoO) issue processors, that support non-blocking caches, speculative execution, and state-of-the-art branch prediction. Visit [SimpleScalar](http://www.simplescalar.com/)'s 'Downloads' section to download the tool or the 'Documentation' section to learn about the internals and execution steps.

## Setup

Download the contents of this repository in the same directory as the SimpleScalar toolset source files (obtained from the 'Downloads' section), maintaining the hierarchy. Follow the instructions in the `README` provided by SimpleScalar to build and install. In this exercise, I'll built the toolset on Linux with PISA (Portable ISA) target. To replicate the same, run the below commands in the directory where SimpleScalar is downloaded:

``` 
make config-pisa
make
```

To verfify the build, run any of the various simulator models provided by SimpleScalar (sim-fast, sim-safe, sim-outorder, etc. - more information about each of these in the official documentation) on any of the tests corresponding to the target built:

```
./sim-outorder tests-pisa/bin.little/test-math
```

This should publish the output of the test and various simulation statistics. 

To change the configuration of the processor (cache latencies, cache configuration, number of functional units, branch predictor, etc.), run the below command and supply the parameters to be modified appropiately through command line options or by providing a config file.

```
./sim-outorder -h
```

To be able to execute our own binaries on the simulators, one has to employ a cross-compiler to generate executables for the PISA/Alpha targets. Please read the official documentation on how to setup `gcc-2.6.3` along with the cross-compiler and follow [this](https://github.com/sdenel/How-to-install-SimpleScalar-on-Ubuntu) tutorial by *@sdenel* to solve numerous conflicts during the build process. Once the cross-compiler is setup successfully, one can cross-compile to executables on appropiate targets (PISA/Alpha). Example:

```
bin/sslittle-na-sstrix-gcc -g -O -o mytests/bpred_corr_branch mytests/bpred_corr_branch.c
```

For more information, see the attached [Makefile](https://github.com/layman-n-ish/Tests-on-Simple-Scalar/blob/master/Makefile).

## How to run tests

Once the project is built with my included tests (by executing my Makefile), run the `run_analysis.sh` bash script to automate the task of running my designed tests on the `sim-outorder` simulator with PISA target.

```
Usage: ./run_analysis.sh [ANALYSIS_TYPE] [TEST_FILE_PATH] [DEBUG]
```
- `ANALYSIS_TYPE` can be 'b' for running branch predictors' test or 'c' for executing analysis on cache-oblivious algorithms.
- `TEST_FILE_PATH` takes in the path to the executable to run the `sim-outorder` simulator on. Irrelevant when `ANALYSIS_TYPE` == 'c'.
- `DEBUG` only when '1' prints useful stats and messages about the running tests.

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

A hypothesis I wanted to prove was how dynamic global predictors should outperform dynamic local predictors on [correlated branch conditionals with a *random* pattern](https://github.com/layman-n-ish/Tests-on-Simple-Scalar/blob/master/mytests/bpred_corr_branch.c); randomness was embedded because only then one can point out the exploitation, by the global predictor, of the auxiliary information about other branch conditionals that global branch history possesses, instead of simply "learning" the pattern itself. This global view lacks in the local predictors ergo their failure in comparison with global predictors. 

For this experiment, I configured various branch predictors ([`myconfig/bpred_*`](https://github.com/layman-n-ish/Tests-on-Simple-Scalar/tree/master/myconfig)) viz. two-level adaptive (and its numerous flavours: GAg, PAg, PAp, gshare), bimodal, hybrid between two-level adaptive and bimodal (named 'comb'), taken, not-taken, etc. Each of these branch predictors were employed sequentially while executing `mytests/bpred_corr_branch.c` which contains the source code for 'executing correlated branch conditionals with random pattern'. Further experiments include modifying parameters of the branch predictor such as history length, table size, etc.  

#### Caches

[Cache-oblivious algorithms](https://en.wikipedia.org/wiki/Cache-oblivious_algorithm), which are subtly different from Cache-aware algorithms as Michael Bender explains in his brief technical paper [Cache-Oblivious and Cache-Aware Algorithms](https://www.tau.ac.il/~stoledo/csc04/Bender.pdf), are algorithms written craftily to exploit how caches work and their structure in order to attain superior asymptotic time complexity. As the name suggests, these algorithms are *oblivious* to the memory heirarchy and ergo are anticipated to work flawlessly even on machines with different cache levels, cache line size, etc. than the machine on which such algorithms were tested on. 

Accessing elements of a martrix in [row-major order](https://en.wikipedia.org/wiki/File:Row_and_column_major_order.svg) is one such cache-oblivious algorithm. Simply because how arrays are stored in memory and how caches fetch blocks of sequential localized data from memory during a cache-miss, accessing elements from a matrix in row-major order ([`mytests/caching_row_major.c`](https://github.com/layman-n-ish/Tests-on-Simple-Scalar/blob/master/mytests/caching_row_major.c)) looks advantageous than accessing elements in column-major order ([`mytests/caching_col_major.c`](https://github.com/layman-n-ish/Tests-on-Simple-Scalar/blob/master/mytests/caching_col_major.c)) because every access results in a cache-miss in the latter case as it fetches the incorrect block in the top-level cache (assuming cache pre-fetchers are absent).

**Configurations**: The L1 data cache is of 16KiB (128 sets, 32B block size, 4 associativity) and the L2 data cache is of 256KiB (1024 sets, 64B block size, 4 associativity). Both level caches have 'LRU' as their block replacement policies.

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

Relevant simulation results can be found under [`results/result_bpred_*`](https://github.com/layman-n-ish/Tests-on-Simple-Scalar/tree/master/results). Complete simulation results can be found under [`output-sim/test_bpred_*`](https://github.com/layman-n-ish/Tests-on-Simple-Scalar/tree/master/output-sim).

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

- The affects on `sim_elapsed_time` & `sim_IPC` for column-major order w.r.t row-major order can be seen amplified if we decrease the cache hit latencies (`-cache:dl1lat` and `-cache:dl2lat`) and increase the memory access latency (`-mem:lat`) in both the [`myconfig/caching_*.cfg`](https://github.com/layman-n-ish/Tests-on-Simple-Scalar/tree/master/myconfig) files. 

Relevant simulation results can be found under [`results/result_caching_*`](https://github.com/layman-n-ish/Tests-on-Simple-Scalar/tree/master/results). Complete simulation results can be found under [`output-sim/test_cache_*`](https://github.com/layman-n-ish/Tests-on-Simple-Scalar/tree/master/output-sim).

## Future Work

- Debug experiments on branch predictors.
- Try row-major order and column-major order traversal for diverse cache configurations.
- Prove row-major order traversal is cache-**oblivious** by experimenting on different memory hierarchies and expecting similar results throughout.  
- Add more cache-oblivious algorithms.
