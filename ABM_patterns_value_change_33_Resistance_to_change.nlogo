breed [needs need]
breed [humans human]
breed [technologies technology]
breed [moral_problems moral_problem]
breed [values value]
breed [arrows arrow]
breed [crosses cross]
breed [pluses plus]

Globals [
  list_colors_values
  list_colors_moral_problems
  coordinate_base_humans
  coordinate_base_new_values
  coordinate_base_innovation
  coordinate_base_technologies
  list_colors_moral_problems_rbg
  duration_last_innovation_succesful
  duration_last_innovation_unsuccesful

  Time_since_unacceptable_technology_was_used
  Maximum_time_no_unacceptable_technologies_were_used

  value_change_last_x_ticks
  sum_variance_importance_of_values
  patches_innovation_area

  Moral_revolution_occured
  Moral_revolution_occured_true_false


  this_seed
  start_seed


  ; metrics
  number_of_values
  Variance_importance_of_values
  list_variance_importance_of_values

  number_of_technologies
  number_of_unacceptable_technologies

  number_of_moral_problems
  number_of_perceived_moral_problems
  number_of_unperceived_moral_problems
  number_of_moral_problems_emerged
  number_of_moral_problems_discovered_through_threshold
  number_of_moral_problems_discovered_through_values
  severity_of_moral_problems

  list_duration_problem_solving
  average_duration_problem_solving

  lock_in_situtation
  lock_in_situtation_true_false
  list_lock_in_technologies
  count_lock_in_situtations

]

needs-own [
  need_number
  size_need
  need_activated?
  human_addressing_me
  my_moral_problems

]

values-own [
  id
  value_importance
  list_moral_problems_addressed
  list_temporary_changes
  duration_since_last_related_moral_problem
  value_importance_previous_tick
]

humans-own [
  need_I_fullfil
  status_human
  technology_picked
  last_technology_picked
  values_to_change
  new_values_to_make
  new_technologies_created
  successive_use_unacceptable_technology


]

technologies-own [
  id
  transported_technology?
  need_I_can_address
  list_negative_impact
  performance_level
  human_to_follow
  parent_technology
  acceptable_technology?
  degree_unacceptability
  duration_last_use_technology

]

moral_problems-own [
  my_need
  status_moral_problem
  size_moral_problem
  my_negative_impact
  my_rgb_color
  duration
  duration_since_last_affected
]

arrows-own [
  duration
  my_value
]

crosses-own [
  value_or_technology
  id
  duration
]

pluses-own [
  duration
  value_or_technology
  who_to_follow
]





to setup
  ca
  reset-ticks

  let new_seed new-seed
  set this_seed new_seed

  set start_seed 500
  if Fix_values_techs_needs_at_beginning = true [random-seed start_seed]

  ;start_seed

  set coordinate_base_new_values [0 120]
  set coordinate_base_innovation [-160 -130]
  set coordinate_base_technologies [100 -120]
  set coordinate_base_humans [250 0]

  set duration_last_innovation_succesful 1000
  set duration_last_innovation_unsuccesful 1000

  ask patches [set pcolor white]
  set patches_innovation_area patches with [distancexy item 0 coordinate_base_innovation item 1 coordinate_base_innovation < 10]
  ask patches with [distancexy item 0 coordinate_base_humans item 1 coordinate_base_humans < 10][set pcolor 8]
  ask patches_innovation_area [set pcolor 8]

  if Propensity_value_dynamism = 0 and Propensity_value_adaptation = 0 and Propensity_innovation = 0 [
    set Propensity_value_dynamism 1
    set Propensity_value_adaptation 1
    set Propensity_innovation 1]

  set value_change_last_x_ticks []
  set list_variance_importance_of_values []
  set list_lock_in_technologies []


  set list_duration_problem_solving []

  ; create list shapes
  let list_shapes (list "food" "house" "computer workstation" "electric outlet" "car" "telephone" "drop" "campsite" "ambulance" "ball football")

  ; set colors moral problems
  let list_colors_moral_problems_rbg_basis
    [[2 63 165] [125 135 185] [190 193 212] [214 188 192] [187 119 132] [142 6 59] [74 111 227] [133 149 225] [181 187 227]
      [230 175 185] [224 123 145] [211 63 106] [17 198 56] [141 213 147] [198 222 199] [234 211 198] [240 185 141]
      [239 151 8] [15 207 192] [156 222 214] [213 234 231] [243 225 235] [246 196 225] [247 156 212]]

  ; multiply list of colors by 4
  set list_colors_moral_problems_rbg list_colors_moral_problems_rbg_basis
  let counter_item 0
  repeat 3 [
    foreach list_colors_moral_problems_rbg_basis [x ->
      let new_color x
      set new_color replace-item counter_item new_color ((item counter_item new_color + 50) mod 255)
      set list_colors_moral_problems_rbg lput new_color list_colors_moral_problems_rbg]
    set counter_item counter_item + 1]

  ;;;;;;;;;;;;;;;;;;;;   create-needs   ;;;;;;;;;;;;;;;;;;;;



  let counter_needs 0
  create-needs round(Number_of_needs) [

    ; shape
    set shape item counter_needs list_shapes
    set color 8

    set size_need random-normal 6 2
    if size_need < 1 [set size_need 1]
    if size_need > 10 [set size_need 10]
    set size 15

    ; id
    set need_number counter_needs

    ;placement
    let total_height max-pycor * 2
    let step_height total_height / ((round(round(Number_of_needs)) + 3) + 2 )
    let this_ycor min-pycor + (step_height * 2) + (step_height * (counter_needs + 1))
    setxy -225 this_ycor

    ;other parameters
    set need_activated? false
    set my_moral_problems nobody

    ; counter
    set counter_needs counter_needs + 1

  ]

  ;;;;;;;;;;;;;;;;;;;;   create-values   ;;;;;;;;;;;;;;;;;;;;



  let counter_values 0
  let temp_Initial_number_of_values 0
  ifelse Switch_on_values = False [set temp_Initial_number_of_values 0]  ; 9 values
  [set temp_Initial_number_of_values Initial_number_of_values]
  create-values round(round(temp_Initial_number_of_values)) [
    set value_importance random-float 10

    ; shape
    set shape "suit heart"
    set size value_importance + 5

    ; other parameters
    set list_temporary_changes []
    set list_moral_problems_addressed []
    repeat (random 3) + 1 [
      let random_moral_problem random round(number_negative_impacts)
      while [member? random_moral_problem list_moral_problems_addressed = true][
        set random_moral_problem random round(number_negative_impacts)]
      set list_moral_problems_addressed lput random_moral_problem list_moral_problems_addressed]
    set duration_since_last_related_moral_problem 0
    set id who

    let my_color get_color_value
    set color approximate-hsb item 0 my_color item 1 my_color item 2 my_color


    ; counter
    set counter_values counter_values + 1

  ]

  ; placement values
  placement_values

    ;;;;;;;;;;;;;;;;;;;;   create-technologies   ;;;;;;;;;;;;;;;;;;;;



  let counter_technologies 0
  let ratio_technology_needs 2
  create-technologies round(Number_of_needs) * ratio_technology_needs  [   ;18 technologies

    ; shape
    set shape "hammer"
    set heading 0
    set color black
    set size 15

    ; list negative impacts
    set list_negative_impact []
    ;let number_neg_impact_above_0 round((0.1 * number_negative_impacts) + (number_negative_impacts * 0.4 * (magnitude_neg_impact / 100)))
    ;let number_neg_impact_above_0 round((0 * number_negative_impacts) + (number_negative_impacts * 0.4 * (magnitude_neg_impact / 100)))
    let number_neg_impact_above_0 round(random-normal ((0 * number_negative_impacts) + (number_negative_impacts * 0.4 * (magnitude_neg_impact / 100))) 1)
    if number_neg_impact_above_0 < 1 [set number_neg_impact_above_0 1]

    let number_neg_impact_0 number_negative_impacts - number_neg_impact_above_0
    repeat round(number_negative_impacts) [
      let random_number random 2
      let new_parameter 0
      if random_number = 0 [
        ifelse number_neg_impact_0 > 0 [
          set new_parameter 0
          set number_neg_impact_0 number_neg_impact_0 - 1][
          set number_neg_impact_above_0 number_neg_impact_above_0 - 1
          set new_parameter 1 + random 10]]
      if random_number = 1 [
        ifelse number_neg_impact_above_0 > 0 [
          set new_parameter 1 + random 10
          set number_neg_impact_above_0 number_neg_impact_above_0 - 1][
          set new_parameter 0
          set number_neg_impact_0 number_neg_impact_0 - 1]]

        ;let new_parameter random-gamma 1  (1 / magnitude_neg_impact) ;random-poisson 3
      ;let new_parameter (0.00045 * exp((random-float 10) * 2)/ 22000)
      ;if new_parameter > 10 [set new_parameter 10]
      set list_negative_impact lput new_parameter list_negative_impact]
    ;print list_negative_impact

    ; performance level
    set performance_level random-float 8 + 2

    ;other parameters
    set transported_technology? false
    set need_I_can_address one-of needs with [count technologies with [need_I_can_address = myself] < ratio_technology_needs]
    set human_to_follow False
    set parent_technology nobody
    set duration_last_use_technology 0
    set id who

    set counter_technologies counter_technologies + 1]

  ; placement technologies
  placement_technologies


  ;;;;;;;;;;;;;;;;;;;;   create moral problems   ;;;;;;;;;;;;;;;;;;;;

  let counter_needs_2 0
  repeat round(Number_of_needs) [
    let counter_moral_problems 0
    create-moral_problems round(number_negative_impacts) [
      set shape "warning"
      set size 10
      set my_need need counter_needs_2
      set my_negative_impact counter_moral_problems
      move-to my_need
      ask my_need [set my_moral_problems (turtle-set myself my_moral_problems)]
      set status_moral_problem "no_problem"
      ;set color item counter_moral_problems list_colors_moral_problems
      let my_colour item counter_moral_problems list_colors_moral_problems_rbg
      ;print ""
      ;print counter_moral_problems
      ;print my_colour
      set color approximate-hsb item 0 my_colour item 1 my_colour item 2 my_colour
      set my_rgb_color my_colour

      ht
  set counter_moral_problems counter_moral_problems + 1
  ]
  set counter_needs_2 counter_needs_2 + 1]


  ;;;;;;;;;;;;;;;;;;;;   create population   ;;;;;;;;;;;;;;;;;;;;

  let counter_humans 0
  create-humans round(Number_of_needs) [

    ; shape
    set shape "person"
    set heading 0
    set color black
    ifelse Visualize_humans = true [
      set size 10][
      set size 0]

    ;placement
    setxy item 0 coordinate_base_humans item 1 coordinate_base_humans
    set status_human "ready_to_serve"

    ;other parameters
    set need_I_fullfil need counter_humans
    ask need_I_fullfil [set human_addressing_me myself]
    set values_to_change []
    set new_values_to_make []
    set technology_picked nobody
    set last_technology_picked nobody

    set counter_humans counter_humans + 1
  ]


  set Moral_revolution_occured 0
  set Moral_revolution_occured_true_false False


  if Fix_values_techs_needs_at_beginning = true [random-seed this_seed]

end






to go


  if prints_on = true [print "time 0"]
  ask values [set value_importance_previous_tick value_importance]



  if Switch_on_values = false [ask values [die]
    ask humans with [status_human = "Value_emergence"][set new_values_to_make []
  set status_human "Back_to_base"]]

  ;;; Needs can change over time
  if Sizes_of_needs_are_changing_over_time = true [
    ask needs [
      if ticks mod frequency_of_need_change = 0 [
        let temp_size_need random-float (max_need_change * 2) - max_need_change
        if size_need + temp_size_need > 10 [set temp_size_need temp_size_need * -1]
        if size_need + temp_size_need < 0 [set temp_size_need temp_size_need * -1]
        if size_need > 6 [set temp_size_need -2.5]
        set size_need size_need + temp_size_need]]]

  ;;; some needs get activated
  ask needs [
    if need_activated? = false and [status_human] of human_addressing_me = "ready_to_serve" [
      let chance_activation 500
      if random-float 1 < chance_activation [
        set need_activated? true
        set color blue]]]
  if prints_on = true [print "time 1"]
  ;;; human fulfill needs
  ask humans [
    if [need_activated?] of need_I_fullfil = true and status_human = "ready_to_serve" [
      ; select technology and go to it
      let potential_technologies technologies with [need_I_can_address = [need_I_fullfil] of myself and transported_technology? = false and acceptable_technology? = true]
      if count potential_technologies = 0 [
        set potential_technologies technologies with [need_I_can_address = [need_I_fullfil] of myself and transported_technology? = false]]
      ;;; then highly performance
      let highest_performance_technology max [performance_level] of potential_technologies
      set potential_technologies technologies with [performance_level = highest_performance_technology]

      let selected_technology nobody
      ifelse count potential_technologies = 1 [
        set selected_technology one-of potential_technologies][
        let technology_with_min_who one-of potential_technologies
        ask potential_technologies [
          if who < [who] of technology_with_min_who [
            set technology_with_min_who self]]
        set selected_technology technology_with_min_who]
      face selected_technology
      fd min (list round(speed_humans) distance selected_technology)

      ; if at technology
      if (abs(xcor - [xcor] of selected_technology) < 0.01) and (abs(ycor - [ycor] of selected_technology) < 0.01) [
        move-to selected_technology
        ; pick up technology
        ask selected_technology [
          set duration_last_use_technology 0
          set performance_level min (list 10 (performance_level + increase_performance_level_each_use))
          let human_to_follow_temp myself
          hatch 1 [
            set transported_technology? true
            ifelse Visualize_humans = true [set size 15]
            [set size 0]
            set parent_technology myself
            set size 15
            set human_to_follow human_to_follow_temp
            ask human_to_follow_temp [set technology_picked myself
              set last_technology_picked [who] of myself]]]
        set status_human "technology_picked_up"]]

    if prints_on = true [print "time 1.1"]

    if [need_activated?] of need_I_fullfil = true and status_human = "technology_picked_up" [
      face need_I_fullfil
      fd min (list round(speed_humans) distance need_I_fullfil)
      ask technology_picked [
        set xcor [xcor] of myself
        set ycor [ycor] of myself]
      if (abs(xcor - [xcor] of need_I_fullfil) < 0.01) and (abs(ycor - [ycor] of need_I_fullfil) < 0.01) [
        ;print [performance_level] of technology_picked
        move-to need_I_fullfil
        ; address need, which could result in moral problems
        ask need_I_fullfil [
          let technology_addressing_me [technology_picked] of myself
          ; copy list of neg impact
          let list_neg_impact_of_tech [list_negative_impact] of [technology_picked] of myself
          let counter_list_neg_impact 0
          foreach list_neg_impact_of_tech [x ->

            ask one-of my_moral_problems with [my_negative_impact = counter_list_neg_impact][
              let technology_causing_me technology_addressing_me
              ;let increase_moral_problem x * factor_increase_moral_problem * [size_need] of myself / [performance_level] of technology_causing_me
              ;let factor_correction [size_need] of myself * 2
              ;if [size_need] of myself < 5
              let correction_size_need [size_need] of myself + ([size_need] of myself * (([size_need] of myself) - 5) / 5)
              ;print ""
              ;print [size_need] of myself
              ;print correction_size_need

              let increase_moral_problem x * factor_increase_moral_problem * correction_size_need / [performance_level] of technology_causing_me
              set size_moral_problem min (list (size_moral_problem + increase_moral_problem) 10)
              ;set duration_since_last_affected 0
              if x > 0 [set duration_since_last_affected 0]
              set size size_moral_problem * .1
              let previous_status_moral_problem status_moral_problem
              if size_moral_problem >= threshold_existence_moral_problem [
                st
                set color white
                if previous_status_moral_problem = "no_problem" [set number_of_moral_problems_emerged number_of_moral_problems_emerged + 1]
                set status_moral_problem "unaware_problem"

                if size_moral_problem > threshold_awareness_moral_problems [  ;;;;;;;;;;;;;; or if a value exists
                  if status_moral_problem = "unaware_problem" [set number_of_moral_problems_discovered_through_threshold number_of_moral_problems_discovered_through_threshold + 1]
                  set status_moral_problem "aware_problem"
                  set color approximate-hsb item 0 my_rgb_color item 1 my_rgb_color item 2 my_rgb_color ]
                if previous_status_moral_problem = "no_problem" and (status_moral_problem = "unaware_problem" or status_moral_problem = "aware_problem") [set number_of_moral_problems_emerged number_of_moral_problems_emerged + 1]
                ;if (previous_status_moral_problem = "no_problem" or previous_status_moral_problem = "unaware_problem") and status_moral_problem = "aware_problem" [set number_of_moral_problems_discovered_through_values number_of_moral_problems_discovered + 1]

            ]]
            set counter_list_neg_impact counter_list_neg_impact + 1]
          ;;;; also ask values to check whether they recognize one of the problems
          ask values [
            let recognized_problem false
            let need_to_evaluate myself
            let moral_problems_to_evaluate moral_problems with [my_need = need_to_evaluate and member? my_negative_impact [list_moral_problems_addressed] of myself = true]
            if count moral_problems_to_evaluate with [size_moral_problem > threshold_existence_moral_problem] = length list_moral_problems_addressed [
              set recognized_problem true]
            if recognized_problem = true [
              ask moral_problems_to_evaluate [
                if status_moral_problem = "unaware_problem" or status_moral_problem = "no_problem" [set number_of_moral_problems_discovered_through_values number_of_moral_problems_discovered_through_values + 1]
                set status_moral_problem "aware_problem"
                set color approximate-hsb item 0 my_rgb_color item 1 my_rgb_color item 2 my_rgb_color]]]
          set need_activated? False
          set color 8

          ; ask need to reorganize moral problems
          let agentset_problems my_moral_problems with [status_moral_problem = "unaware_problem" or status_moral_problem = "aware_problem"]
          let list_agentset_problems_by_neg_impact sort-on [my_negative_impact] agentset_problems

          let counter_visible_moral_problems 0
          foreach list_agentset_problems_by_neg_impact [x ->
            let total_width 80
            let step_width total_width / (round(round(count agentset_problems)) + 3)
            let this_xcor -245 - (step_width * counter_visible_moral_problems)
            ask x [setxy this_xcor [ycor] of myself]
            set counter_visible_moral_problems counter_visible_moral_problems + 1]

          ask my_moral_problems with [status_moral_problem = "no_problem"] [
            move-to myself
            ht]]

        ; decide whether to change values or proceed to innovation
        ;; We do when the problem is perceived (even if the problem was already there)

        ; First we check whether there already exists a value (i.e. whether the human can understand the moral problem(s) based on current values)

        let list_moral_problems_observed []
        if Switch_on_values = true [
          ask need_I_fullfil [set list_moral_problems_observed [my_negative_impact] of my_moral_problems with [status_moral_problem = "aware_problem"]]]

        ; ask all values to check whether they can resolve the problem
        let counter_number_of_items length list_moral_problems_observed
        set values_to_change []
        set new_values_to_make []
        let copy_list_moral_problems_observed list_moral_problems_observed
        while [counter_number_of_items > 0][

          ask values with [length list_moral_problems_addressed = counter_number_of_items][
            let all_moral_problem_addressed? true
            foreach list_moral_problems_addressed [x ->
              if member? x copy_list_moral_problems_observed = false [set all_moral_problem_addressed? false]]
            if all_moral_problem_addressed? = true [
              ask myself [set values_to_change lput myself values_to_change]
              foreach list_moral_problems_addressed [x ->
                set copy_list_moral_problems_observed remove x copy_list_moral_problems_observed]
              set counter_number_of_items length copy_list_moral_problems_observed]]
          set counter_number_of_items counter_number_of_items - 1]
        set values_to_change sort values_to_change


        ; now check if there are still moral problems remaining and hence if we need to make new values

        if length copy_list_moral_problems_observed > 0 [

          while [length copy_list_moral_problems_observed > 0][
            let moral_problems_addressed_new_value []
            repeat min (list 3 length copy_list_moral_problems_observed)[
              let number_picked one-of copy_list_moral_problems_observed
              set moral_problems_addressed_new_value lput number_picked moral_problems_addressed_new_value
              set copy_list_moral_problems_observed remove number_picked copy_list_moral_problems_observed]

            let chance_value_emergence random-float 1
            if chance_value_emergence < (Openness_to_change / 100) [
              set new_values_to_make lput moral_problems_addressed_new_value new_values_to_make]]]

        if Switch_on_values = false [
          set values_to_change sentence values_to_change new_values_to_make
          set new_values_to_make []]


        ;;;;;; now check if only make new values or both new value and whether the other choice is
        ifelse length new_values_to_make > 0 [
          set status_human "Value_emergence"
            placement_values][
          ifelse length values_to_change > 0 [
            let number_of_aware_moral_problems 0
            ask need_I_fullfil [set number_of_aware_moral_problems count my_moral_problems with [status_moral_problem = "aware_problem"]]
            if number_of_aware_moral_problems  > 0 [
              set status_human decide_value_change_or_innovation]]
          [set status_human "Back_to_base"]]
        ask technology_picked [die]]]

    if prints_on = true [print "time 1.2"]
    if status_human = "Value_emergence" [
      placement_values

      let initial_margin 100
      let total_width max-pxcor * 2 - initial_margin

      let number_of_new_values_to_be_created 0
      ask humans [set number_of_new_values_to_be_created number_of_new_values_to_be_created + length new_values_to_make]
      let step_width total_width / (round(round(count values + number_of_new_values_to_be_created)) + 3)

      let coordinate_to_go 0
      ifelse any? values [
        set coordinate_to_go (list ([xcor] of one-of values with [who = max [who] of values] + step_width) ([ycor] of one-of values with [who = max [who] of values]))]
      [set coordinate_to_go coordinate_base_new_values]
      facexy item 0 coordinate_to_go item 1 coordinate_to_go
      fd min (list round(speed_humans) distancexy item 0 coordinate_to_go item 1 coordinate_to_go)
      if (abs(xcor - item 0 coordinate_to_go) < 0.01) and (abs(ycor - item 1 coordinate_to_go) < 0.01) [
        setxy item 0 coordinate_to_go item 1 coordinate_to_go
        ;print new_values_to_make
        foreach new_values_to_make [new_value ->
          hatch-values 1 [
            set list_temporary_changes []
            set shape "suit heart"
            set value_importance 3
            set size value_importance + 5
            set list_moral_problems_addressed new_value
            let new_color get_color_value
            set duration_since_last_related_moral_problem 0
            set color approximate-hsb item 0 new_color item 1 new_color item 2 new_color
            ;set color random 130
            set id who
            hatch-pluses 1 [
              set color green
              set size 10
              set heading 180
              fd 10
              set duration 200
              set shape "plus"
              set value_or_technology "value"
              set who_to_follow myself]]
        placement_values]

        set new_values_to_make []
        ; after that we need to check if there is still something to do with values_to_change
        ifelse length values_to_change > 0 [set status_human decide_value_change_or_innovation]
        [set status_human "Back_to_base"]]]

    if prints_on = true [print "time 1.3"]
    if status_human = "Value_adaptation" [
      let this_value_to_change item 0 values_to_change
      face this_value_to_change
      fd min (list round(speed_humans) distance this_value_to_change)
      if (abs(xcor - [xcor] of this_value_to_change) < 0.01) and (abs(ycor - [ycor] of this_value_to_change) < 0.01) [
        move-to this_value_to_change
        let human_asking self
        ask this_value_to_change [
          hatch-arrows 1 [
            set shape "arrow"
            set size 5
            set heading 0
            set color red
            set my_value myself
            fd 10
            set duration 200]

          let size_of_moral_problems_addressed 0
          foreach list_moral_problems_addressed [ x ->       ;;;;; check if this is a list, or a combination of problems
            set size_of_moral_problems_addressed size_of_moral_problems_addressed + [size_moral_problem] of one-of moral_problems with [my_negative_impact = x and my_need = [need_I_fullfil] of human_asking]]
          let increase_value_importance Openness_to_change / 100 * (0.4 * size_of_moral_problems_addressed)

          ;print size_of_moral_problems_addressed
          set value_importance min (list (value_importance + increase_value_importance) 10)
          set size value_importance + 5
          set duration_since_last_related_moral_problem 0]
        set values_to_change remove-item 0 values_to_change
        if length values_to_change = 0 [set status_human "Back_to_base"]]]

    if prints_on = true [print "time 1.4"]
    if status_human = "Value_dynamism" [
      let this_value_to_change item 0 values_to_change
      face this_value_to_change
      fd min (list round(speed_humans) distance this_value_to_change)
      if (abs(xcor - [xcor] of this_value_to_change) < 0.01) and (abs(ycor - [ycor] of this_value_to_change) < 0.01) [
        move-to this_value_to_change
        let human_asking self
        ask this_value_to_change [
          hatch-arrows 1 [
            set shape "arrow"
            set size 5
            set heading 0
            set color red
            set my_value myself
            fd 10
            set duration 200]
          let size_of_moral_problems_addressed 0
          foreach list_moral_problems_addressed [ x ->       ;;;;; check if this is a list, or a combination of problems
            set size_of_moral_problems_addressed size_of_moral_problems_addressed + [size_moral_problem] of one-of moral_problems with [my_negative_impact = x and my_need = [need_I_fullfil] of human_asking]]
          let increase_value_importance Openness_to_change / 100 * (0.4 * size_of_moral_problems_addressed)
          set value_importance min (list (value_importance + increase_value_importance) 10)
          set size value_importance + 5
          set list_temporary_changes lput (list 1 duration_value_dynamism) list_temporary_changes
          set duration_since_last_related_moral_problem 0]

        set values_to_change remove-item 0 values_to_change
        if length values_to_change = 0 [set status_human "Back_to_base"]]]
    if prints_on = true [print "time 1.5"]
    if status_human = "Innovate" [
      facexy item 0 coordinate_base_innovation item 1 coordinate_base_innovation
      fd min (list round(speed_humans) distancexy item 0 coordinate_base_innovation item 1 coordinate_base_innovation)
      if (abs(xcor - item 0 coordinate_base_innovation) < 0.01) and (abs(ycor - item 1 coordinate_base_innovation) < 0.01) [
        setxy item 0 coordinate_base_innovation item 1 coordinate_base_innovation
        set new_technologies_created []
        foreach values_to_change [x ->

          if random-float 1 < (Openness_to_change / 250) [
            set new_technologies_created lput x new_technologies_created]]
        ifelse length new_technologies_created = 0 [set status_human "Back_to_base"
          set values_to_change []
          set duration_last_innovation_unsuccesful 0][
          set duration_last_innovation_succesful 0
          foreach new_technologies_created [x ->


            hatch-technologies 1 [
              set shape "hammer"
              set heading 0
              set color black
              set size 15
              set id who

              ;;;; Evaluate the max neg impact that a technology may have based on current values
              let max_neg_impact []
              repeat round(number_negative_impacts) [set max_neg_impact lput 10 max_neg_impact]
              ask values [
                foreach list_moral_problems_addressed [max_impact ->
                  set max_neg_impact replace-item max_impact max_neg_impact min(list item max_impact max_neg_impact (10 - value_importance))]]

              ;create a dummy list
              let dummy_list_negative_impact []
              ;let number_neg_impact_above_0 round((0.1 * number_negative_impacts) + (number_negative_impacts * 0.4 * (magnitude_neg_impact / 100)))
              ;let number_neg_impact_above_0 round((0 * number_negative_impacts) + (number_negative_impacts * 0.4 * (magnitude_neg_impact / 100)))
              let number_neg_impact_above_0 round(random-normal ((0 * number_negative_impacts) + (number_negative_impacts * 0.4 * (magnitude_neg_impact / 100))) 1)
              if number_neg_impact_above_0 < 1 [set number_neg_impact_above_0 1]

              let number_neg_impact_0 number_negative_impacts - number_neg_impact_above_0
              repeat round(number_negative_impacts) [
                let random_number random 2
                let new_parameter 0
                if random_number = 0 [
                  ifelse number_neg_impact_0 > 0 [
                    set new_parameter 0
                    set number_neg_impact_0 number_neg_impact_0 - 1][
                    set number_neg_impact_above_0 number_neg_impact_above_0 - 1
                    set new_parameter 1 + random 10]]
                if random_number = 1 [
                  ifelse number_neg_impact_above_0 > 0 [
                    set new_parameter 1 + random 10
                    set number_neg_impact_above_0 number_neg_impact_above_0 - 1][
                    set new_parameter 0
                    set number_neg_impact_0 number_neg_impact_0 - 1]]
                set dummy_list_negative_impact lput new_parameter dummy_list_negative_impact]
              let points_to_distribute sum dummy_list_negative_impact


              let temp_list_characteristics []
              repeat round(number_negative_impacts) [
                set temp_list_characteristics lput 0 temp_list_characteristics]

            let distribution_chance_characteristics []
            let counter_values_2 0
            let emphasis_chances_on_none_existing_values 4
            repeat round(number_negative_impacts) [
              let this_chance item counter_values_2 max_neg_impact
              ifelse this_chance = 10 [set this_chance this_chance * emphasis_chances_on_none_existing_values]
              [set this_chance this_chance * (1 / emphasis_chances_on_none_existing_values)]
              set distribution_chance_characteristics lput this_chance distribution_chance_characteristics
                set counter_values_2 counter_values_2 + 1]
              let distribution_chances [0]
              let sum_chances sum distribution_chance_characteristics


              let counter_item_distribution 0
              let counter_ratios 0
              repeat round(number_negative_impacts)[
                let this_ratio 0
                ifelse sum_chances <= 0 [set this_ratio 0.1][
                  set this_ratio (item counter_item_distribution distribution_chance_characteristics) / sum_chances]
                set counter_ratios counter_ratios + this_ratio
                set distribution_chances lput counter_ratios distribution_chances
                set counter_item_distribution counter_item_distribution + 1]

              while [points_to_distribute > 0][
                ifelse max distribution_chances <= 0 [
                  set temp_list_characteristics []
                  repeat round(number_negative_impacts) [set temp_list_characteristics lput 10 temp_list_characteristics]
                  set points_to_distribute 0]
                [let random_number random-float max distribution_chances  ;;;;; set this to the max of distribution list
                  let counter_distribution 0
                  while [random_number > item counter_distribution distribution_chances][
                    set counter_distribution counter_distribution + 1]
                  let item_to_take_temp_list_characteristics counter_distribution - 1
                  ifelse item item_to_take_temp_list_characteristics temp_list_characteristics = 10 [
                    let current_chance item counter_distribution distribution_chances - item (counter_distribution - 1 ) distribution_chances
                    set distribution_chances replace-item counter_distribution distribution_chances item (counter_distribution - 1) distribution_chances
                    let counter_distribution_chances 0
                    foreach distribution_chances [ x2 ->
                      if counter_distribution_chances > (counter_distribution) [
                        set distribution_chances replace-item (counter_distribution_chances) distribution_chances (x2 - current_chance)]
                      set counter_distribution_chances counter_distribution_chances + 1]][

                    set temp_list_characteristics replace-item (counter_distribution - 1) temp_list_characteristics (item (counter_distribution - 1) temp_list_characteristics + 1)
                    set points_to_distribute points_to_distribute - 1]]]

              set list_negative_impact temp_list_characteristics

              ; performance level
              set performance_level min (list (2 + random-gamma 1 0.8 ) 10)


              ;other parameters
              set transported_technology? True
              set need_I_can_address [need_I_fullfil] of myself
              set human_to_follow myself
              set parent_technology nobody
              set duration_last_use_technology 0]]
          set status_human "Innovation_created"
          ;set values_to_change remove-item 0 values_to_change
          set values_to_change []
          placement_technologies]]]

    if prints_on = true [print "time 1.6"]
    if status_human = "Innovation_created" [
      if prints_on = true [print "time 1.6.1"]
      let coordinate_to_go 0
      ifelse any? technologies with [transported_technology? = False][
        set coordinate_to_go (list ([xcor] of one-of technologies with [who = max [who] of technologies with [transported_technology? = False] and transported_technology? = False]) ([ycor] of one-of technologies with [who = max [who] of technologies with [transported_technology? = False] and transported_technology? = False]))]
      [set coordinate_to_go coordinate_base_technologies]

      if prints_on = true [print "time 1.6.2"]
      facexy item 0 coordinate_to_go item 1 coordinate_to_go
      fd min (list round(speed_humans) distancexy item 0 coordinate_to_go item 1 coordinate_to_go)
      ask technologies with [human_to_follow = myself][
        move-to myself]

      if prints_on = true [print "time 1.6.3"]
      if (abs(xcor - item 0 coordinate_to_go) < 0.01) and (abs(ycor - item 1 coordinate_to_go) < 0.01) [
        setxy item 0 coordinate_to_go item 1 coordinate_to_go

        if prints_on = true [print "time 1.6.4"]
        ask technologies with [human_to_follow = myself][
          set transported_technology? False
          set size 15]
        placement_technologies

        if prints_on = true [print "time 1.6.5"]
        ask technologies with [human_to_follow = myself][
          hatch-pluses 1 [
            set color green
            set size 10
            set heading 180
            fd 10
            set duration 200
            set shape "plus"
            set value_or_technology "technology"
            set who_to_follow myself]
        set human_to_follow False]
        set status_human "Back_to_base"]]

    if prints_on = true [print "time 1.7"]
    if status_human = "Back_to_base" [

      facexy item 0 coordinate_base_humans item 1 coordinate_base_humans
      fd min (list round(speed_humans) distancexy item 0 coordinate_base_humans item 1 coordinate_base_humans)

      if (abs(xcor - item 0 coordinate_base_humans) < 0.01) and (abs(ycor - item 1 coordinate_base_humans) < 0.01) [
        setxy item 0 coordinate_base_humans item 1 coordinate_base_humans
        set status_human "ready_to_serve"]]]


  if prints_on = true [print "time 2"]
  ;;;;;; here mechanism to change back the importance of values change temporarily (value dynamism)

  ask values [

    ; update the list_temporary_changes list and evaluate how much of the value importance need to be removed back
    let copy_list_temporary_changes []
    let sum_previously_requested_value_dynamism 0
    let sum_current_requested_value_dynamism 0
    foreach list_temporary_changes [x ->

      set sum_previously_requested_value_dynamism sum_previously_requested_value_dynamism + item 0 x
      let temp_list x
      set temp_list replace-item 1 temp_list (item 1 temp_list - 1)
      let requested_value_change 0
      ifelse item 1 x > (Duration_value_dynamism / 2) [set requested_value_change item 0 x]
      [set requested_value_change (item 0 x) * (item 1 x / (Duration_value_dynamism / 2))]
      set temp_list replace-item 0 temp_list requested_value_change
      if item 1 temp_list > 0 [
        set copy_list_temporary_changes lput temp_list copy_list_temporary_changes
        set sum_current_requested_value_dynamism sum_current_requested_value_dynamism + item 0 temp_list]]

    set list_temporary_changes copy_list_temporary_changes
    set value_importance min (list (max (list (value_importance - (sum_previously_requested_value_dynamism - sum_current_requested_value_dynamism)) 0)) 10)

    ; here we decrease the base_value_importance if a certain problem has not been encountered for a long amount of time
    set duration_since_last_related_moral_problem duration_since_last_related_moral_problem + 1
    ;let diminution_value_importance 0.0005 * (duration_since_last_related_moral_problem ^ ((100 - Value_memory_of_society) / 100)) * (Openness_to_change / 100)
    ;let diminution_value_importance ((duration_since_last_related_moral_problem * .1) ^ 3) * 0.000000015 * ((100 - Value_memory_of_society) / 10 + 1)
    let adjustment_duration_Value_memory_of_society duration_since_last_related_moral_problem * 100
    if Value_memory_of_society > 0 [
      set adjustment_duration_Value_memory_of_society (duration_since_last_related_moral_problem * (100 * ((1 / (Value_memory_of_society)) ^ 1))) - (duration_since_last_related_moral_problem * .8)
      ]
    ;print ""
    ;print duration_since_last_related_moral_problem
    ;print adjustment_duration_Value_memory_of_society
    let diminution_value_importance ((adjustment_duration_Value_memory_of_society * .1) ^ 3) * 0.000000015

    set value_importance max (list (value_importance - diminution_value_importance) 0)

    ; check if value is in any of the list of others humans

    if (value_importance <= 0)[
      let this_myself self
      if count humans with [member? this_myself values_to_change = true] > 0 [
        ask humans with [member? this_myself values_to_change = true][
          set values_to_change remove this_myself values_to_change
          ifelse count other humans with [member? [list_moral_problems_addressed] of this_myself new_values_to_make = true] = 0 [
            set new_values_to_make lput [list_moral_problems_addressed] of this_myself new_values_to_make
            set status_human "Value_emergence"]
          [ifelse length values_to_change > 0 [set status_human decide_value_change_or_innovation]
            [set status_human "Back_to_base"]]]]



      ;let number_of_aware_moral_problems 0
      ;ask need_I_fullfil [set number_of_aware_moral_problems count my_moral_problems with [status_moral_problem = "aware_problem"]]]
      hatch-crosses 1 [
        set color blue
        set size 10
        set heading 0
        set value_or_technology "value"
        set id [id] of myself
        set shape "x"]
      die]


    ;update the size of the value_importance
    set size value_importance + 5]

  if prints_on = true [print "time 3.1"]

  ;;;; here mechanism to decrease the size of moral problems over time
  ask moral_problems [

    let diminution_size_moral_problem (duration_since_last_affected ^ 2) * 0.000000025
    set size_moral_problem max (list (size_moral_problem - diminution_size_moral_problem) 0)
    set size size_moral_problem
    set duration_since_last_affected duration_since_last_affected + 1
    if size_moral_problem < threshold_existence_moral_problem [
      if status_moral_problem = "aware_problem" [set list_duration_problem_solving lput duration list_duration_problem_solving]
      set status_moral_problem "no_problem"
      ht]]

  if prints_on = true [print "time 3.2"]
  ask needs [
    ask values [
      let recognized_problem false
      let need_to_evaluate myself
      let moral_problems_to_evaluate moral_problems with [my_need = need_to_evaluate and member? my_negative_impact [list_moral_problems_addressed] of myself = true]
      if count moral_problems_to_evaluate with [size_moral_problem > threshold_existence_moral_problem] = length list_moral_problems_addressed [
        set recognized_problem true]
      if recognized_problem = true [
        ask moral_problems_to_evaluate [
          set status_moral_problem "aware_problem"
          set color approximate-hsb item 0 my_rgb_color item 1 my_rgb_color item 2 my_rgb_color]]]]

  if prints_on = true [print "time 4"]

  ;;;; here mechanism to change the performance of technologies
  ask technologies with [transported_technology? = false][
    set duration_last_use_technology duration_last_use_technology + 1


    let factor_diminution 0.5
    ;let diminution_performance_level 0.0002 * (duration_last_use_technology ^ factor_diminution)
    ;let diminution_performance_level 0.002 * (0.5 ^ (duration_last_use_technology * 0.005) + 0.00005)
    let diminution_performance_level 0.001
    set performance_level max (list (performance_level - diminution_performance_level) 0)
    if performance_level = 0 and any? other technologies with [transported_technology? = false and need_I_can_address = [need_I_can_address] of myself] [
      hatch-crosses 1 [
        set color blue
        set size 10
        set heading 0
        set value_or_technology "technology"
        set id [id] of myself
        set shape "x"]
      die]]

  if prints_on = true [print "time 5"]

  ;;;; here mechanism to evaluate the acceptability of technologies
  ask technologies [
    let max_neg_impact []
    repeat round(number_negative_impacts) [set max_neg_impact lput 10 max_neg_impact]
    ask values [
      foreach list_moral_problems_addressed [max_impact ->
        set max_neg_impact replace-item max_impact max_neg_impact min(list item max_impact max_neg_impact (10 - value_importance))]]
    let temp_acceptability true
    let temp_degree_unacceptability 0
    let counter_item_acceptability 0
    foreach list_negative_impact [
      if item counter_item_acceptability list_negative_impact > item counter_item_acceptability max_neg_impact [
        set temp_acceptability false]
      set temp_degree_unacceptability temp_degree_unacceptability + (max (list (item counter_item_acceptability list_negative_impact - item counter_item_acceptability max_neg_impact) 0))
      set counter_item_acceptability counter_item_acceptability + 1]
    set acceptable_technology? temp_acceptability
    set degree_unacceptability temp_degree_unacceptability

    ;;;;;;; Here something to evaluate acceptability based on the size of moral problems

    ifelse acceptable_technology? = false [
      set color red][
    set color black]]

  if prints_on = true [print "time 6"]

  ;;;; update arrows and pluses

  ask arrows [set duration duration - 1
    if duration <= 0 [die]]

  ask pluses [set duration duration - 1
    if duration <= 0 [die]]

  ;;; update innovation area
  let duration_innovation_vis 30
  set duration_last_innovation_succesful duration_last_innovation_succesful + 1
  set duration_last_innovation_unsuccesful duration_last_innovation_unsuccesful + 1
  if duration_last_innovation_succesful <= duration_innovation_vis and duration_last_innovation_succesful < duration_last_innovation_unsuccesful [ask patches_innovation_area[set pcolor green]]
  if duration_last_innovation_unsuccesful <= duration_innovation_vis and duration_last_innovation_unsuccesful < duration_last_innovation_succesful [ask patches_innovation_area[set pcolor red]]
  if duration_last_innovation_succesful > duration_innovation_vis and duration_last_innovation_unsuccesful > duration_innovation_vis [
    ask patches_innovation_area[set pcolor 8]]

  ; update duration crosses
  let value_cross_died false
  let tech_cross_died false
  ask crosses [set duration duration + 1
    if duration >= 1000 [
      if value_or_technology = "value" [set value_cross_died true]
      if value_or_technology = "technology" [set tech_cross_died true]
      die]]
  if value_cross_died = true [placement_values]
  if tech_cross_died = true [placement_technologies]

  ;update visualization humans

  if prints_on = true [print "time 7"]
  ifelse Visualize_humans = true [

    ask humans [set size 10]
    ask technologies with [transported_technology? = true] [set size 15]][
    ask humans [set size 0]
    ask technologies with [transported_technology? = true] [set size 0]]

  ; Metrics
  set Time_since_unacceptable_technology_was_used Time_since_unacceptable_technology_was_used + 1
  ask technologies with [transported_technology? = false and acceptable_technology? = false][
    if any? technologies with [transported_technology? = true and parent_technology = myself][
      set Time_since_unacceptable_technology_was_used 0]]
  set Maximum_time_no_unacceptable_technologies_were_used max (list Maximum_time_no_unacceptable_technologies_were_used Time_since_unacceptable_technology_was_used)

  if prints_on = true [print "time 8"]
  let sum_value_change 0
  ask values [
    let my_value_change_last_x_ticks abs (value_importance_previous_tick - value_importance)
    set sum_value_change sum_value_change + my_value_change_last_x_ticks]
  set value_change_last_x_ticks lput sum_value_change value_change_last_x_ticks
  let max_length_list 100
  if length value_change_last_x_ticks > max_length_list [
    set value_change_last_x_ticks remove-item 0 value_change_last_x_ticks]


  set number_of_values count values
  set number_of_technologies count technologies with [transported_technology? = false]
  set number_of_moral_problems count moral_problems with [status_moral_problem = "unaware_problem" or status_moral_problem = "aware_problem"]
  set number_of_perceived_moral_problems count moral_problems with [status_moral_problem = "aware_problem"]
  set number_of_unperceived_moral_problems count moral_problems with [status_moral_problem = "unaware_problem"]
  set severity_of_moral_problems sum [size_moral_problem] of moral_problems with [status_moral_problem = "unaware_problem" or status_moral_problem = "aware_problem"]
  set number_of_unacceptable_technologies count technologies with [transported_technology? = false and acceptable_technology? = false]


  ;average_duration_problem_solving
  ask moral_problems with [status_moral_problem = "unaware_problem" or status_moral_problem = "aware_problem"][set duration duration + 1]
  ask moral_problems with [status_moral_problem = "no_problem"][set duration 0]

  if length list_duration_problem_solving > 0 [
    set average_duration_problem_solving mean list_duration_problem_solving]

  let threshold_lock_in 5
  set lock_in_situtation 0
  ask humans [
    if technology_picked != nobody [
      ifelse [acceptable_technology?] of technology_picked = false[
        set successive_use_unacceptable_technology successive_use_unacceptable_technology + 1][
        set successive_use_unacceptable_technology 0]]
    if successive_use_unacceptable_technology = threshold_lock_in [set count_lock_in_situtations count_lock_in_situtations + 1]
    if successive_use_unacceptable_technology >= threshold_lock_in[
      set lock_in_situtation 1]]
  ifelse lock_in_situtation = 0 [set lock_in_situtation_true_false false][set lock_in_situtation_true_false true]


  let old_list_lock_in_technologies list_lock_in_technologies
  set list_lock_in_technologies []
  let list_humans_orderd sort [who] of humans
  foreach list_humans_orderd [x ->
    ask human x [
      if successive_use_unacceptable_technology >= threshold_lock_in [
        set list_lock_in_technologies lput (word (word "Technology: " last_technology_picked) ", " (word "Need: " [shape] of need_I_fullfil) ", " (word "Human: " [who] of self)"."  ) list_lock_in_technologies

  ]]]

  let checker_compared_lists true

  ifelse length old_list_lock_in_technologies != length list_lock_in_technologies [set checker_compared_lists false][
    let compared_lists (map = old_list_lock_in_technologies list_lock_in_technologies)
  foreach compared_lists [x ->
    if x = false [set checker_compared_lists false]]]

  if checker_compared_lists = false and print_lockins = true[
    clear-output
    foreach list_lock_in_technologies [x ->
      output-print x]]

  ; evaluate if moral revoluation occured
  evaluate_if_moral_revolution_occured

  tick
end

to-report comb [_m _s]
  if (_m = 0) [ report [[]] ]
  if (_s = []) [ report [] ]
  let _rest butfirst _s
  let _lista map [? -> fput item 0 _s ?] comb (_m - 1) _rest
  let _listb comb _m _rest
  report (sentence _lista _listb)
end

to-report decide_value_change_or_innovation

  let distribution_chances [0]

;  let temp_Propensity_value_dynamism Propensity_value_dynamism
;  let temp_Propensity_value_adaptation Propensity_value_adaptation

;  ifelse Switch_on_values = false [
;    set temp_Propensity_value_dynamism 0
;    set temp_Propensity_value_adaptation 0][
;    set temp_Propensity_value_dynamism Propensity_value_dynamism
;    set temp_Propensity_value_adaptation Propensity_value_adaptation]

  let sum_chances Propensity_value_dynamism + Propensity_value_adaptation + Propensity_innovation
  let current_count 0
  set distribution_chances lput (Propensity_value_dynamism / sum_chances) distribution_chances
  set current_count current_count + (Propensity_value_dynamism / sum_chances)
  set distribution_chances lput ((Propensity_value_adaptation / sum_chances) + current_count) distribution_chances
  set current_count current_count + (Propensity_value_adaptation / sum_chances)
  set distribution_chances lput ((Propensity_innovation / sum_chances) + current_count) distribution_chances

  let random_number random-float 1
  let counter_distribution 0

  while [random_number > item counter_distribution distribution_chances][
    set counter_distribution counter_distribution + 1]
  let choice ""
  let choice_id counter_distribution - 1

  if choice_id = 0 [set choice "Value_dynamism"]
  if choice_id = 1 [set choice "Value_adaptation"]
  if choice_id = 2 [set choice "Innovate"]

  report choice

end

to placement_values
  let list_values_and_crosses (turtle-set values crosses with [value_or_technology = "value"])
  set list_values_and_crosses sort [id] of list_values_and_crosses

  let initial_margin 100
  let total_width max-pxcor * 2 - initial_margin
  let number_of_new_values_to_be_created 0
  ask humans [set number_of_new_values_to_be_created number_of_new_values_to_be_created + length new_values_to_make]

  let step_width total_width / (round(round(count values + number_of_new_values_to_be_created + count crosses with [value_or_technology = "value"])) + 3)
  let counter_values 0
  foreach list_values_and_crosses [x ->
    ifelse any? values with [who = x][
      ask one-of values with [id = x] [
      let this_xcor initial_margin + min-pxcor + (step_width * 2) + (step_width * counter_values)
      setxy this_xcor 130
      ask arrows with [my_value = myself] [set xcor this_xcor]
        ask pluses with [who_to_follow = myself and value_or_technology = "value"][set xcor this_xcor]]][
      ask one-of crosses with [id = x] [
      let this_xcor initial_margin + min-pxcor + (step_width * 2) + (step_width * counter_values)
      setxy this_xcor 130]]
    set counter_values counter_values + 1]
end

to placement_technologies
    let list_technologies_and_crosses (turtle-set technologies with [parent_technology = nobody] crosses with [value_or_technology = "technology"])
  set list_technologies_and_crosses sort [id] of list_technologies_and_crosses

  let initial_margin 200
  let final_margin 50
  let total_width max-pxcor * 2 - initial_margin - final_margin
  let step_width total_width / (round(round(length list_technologies_and_crosses)) + 3)
  let counter_technologies 0
  foreach list_technologies_and_crosses [x ->
    ifelse any? technologies with [who = x and parent_technology = nobody][
    ask one-of technologies with [id = x and parent_technology = nobody] [
        let this_xcor initial_margin + min-pxcor + (step_width * 2) + (step_width * counter_technologies)
        setxy this_xcor -130
        ask pluses with [who_to_follow = myself and value_or_technology = "technology"][set xcor this_xcor]]][
      ask one-of crosses with [id = x] [
        let this_xcor initial_margin + min-pxcor + (step_width * 2) + (step_width * counter_technologies)
        setxy this_xcor -130]]
    set counter_technologies counter_technologies + 1]
end

to-report get_color_value
  let list_new_colors []
  foreach list_moral_problems_addressed [x ->
    set list_new_colors lput item x list_colors_moral_problems_rbg list_new_colors]
  ;print ""
  ;print list_moral_problems_addressed
  ;print list_new_colors
  let new_color []
  let counter_color 0
  repeat 3 [
    let color_item 0
    foreach list_new_colors [x ->
      set color_item color_item + item counter_color x]
    set color_item color_item / length list_new_colors
    set new_color lput color_item new_color
    set counter_color counter_color + 1]
  report new_color
end

to evaluate_if_moral_revolution_occured
  ifelse count values > 2 [
    set Variance_importance_of_values variance [value_importance] of values][
    set Variance_importance_of_values 0]
  set list_variance_importance_of_values lput Variance_importance_of_values list_variance_importance_of_values
  let max_length_list 700
  if length list_variance_importance_of_values > max_length_list [set list_variance_importance_of_values remove-item 0 list_variance_importance_of_values]

  ;print list_variance_importance_of_values
  let sum_difference 0
  let length_list_minus_one length list_variance_importance_of_values - 1
  let item_counter 0
  repeat length_list_minus_one [
    set sum_difference sum_difference + abs(item (item_counter + 1) list_variance_importance_of_values - item item_counter list_variance_importance_of_values)
    set item_counter item_counter + 1]

  set sum_variance_importance_of_values sum_difference

  if sum_difference > threshold_moral_revolution and ticks > max_length_list and ticks > 7500 [
    set Moral_revolution_occured 1
    set Moral_revolution_occured_true_false True]
end
@#$#@#$#@
GRAPHICS-WINDOW
295
26
1183
475
-1
-1
1.373
1
10
1
1
1
0
0
0
1
-320
320
-160
160
0
0
1
ticks
30.0

BUTTON
29
63
93
96
Setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
101
63
178
96
Go once
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
187
63
250
96
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
25
268
248
301
Propensity_value_dynamism
Propensity_value_dynamism
0
1
1.0
0.05
1
NIL
HORIZONTAL

SLIDER
25
308
248
341
Propensity_value_adaptation
Propensity_value_adaptation
0
1
1.0
0.05
1
NIL
HORIZONTAL

SLIDER
25
348
248
381
Propensity_innovation
Propensity_innovation
0
1
1.0
0.05
1
NIL
HORIZONTAL

SLIDER
27
181
246
214
Number_of_needs
Number_of_needs
2
10
10.0
1
1
NIL
HORIZONTAL

SLIDER
23
1006
245
1039
Initial_number_of_values
Initial_number_of_values
0
10
5.0
1
1
NIL
HORIZONTAL

SLIDER
23
782
245
815
speed_humans
speed_humans
0
10
5.0
1
1
NIL
HORIZONTAL

SLIDER
23
818
245
851
number_negative_impacts
number_negative_impacts
10
60
30.0
1
1
NIL
HORIZONTAL

SLIDER
23
893
245
926
threshold_awareness_moral_problems
threshold_awareness_moral_problems
0
10
8.0
1
1
NIL
HORIZONTAL

SLIDER
23
931
245
964
duration_value_dynamism
duration_value_dynamism
0
10000
2500.0
100
1
NIL
HORIZONTAL

SLIDER
23
855
245
888
threshold_existence_moral_problem
threshold_existence_moral_problem
0
5
2.0
1
1
NIL
HORIZONTAL

TEXTBOX
480
451
558
469
Innovation area
11
0.0
1

TEXTBOX
792
449
902
467
Available technologies
11
0.0
1

TEXTBOX
1107
222
1177
277
Humans waiting for new requests from needs
11
0.0
1

TEXTBOX
739
34
823
52
Values in society
11
0.0
1

TEXTBOX
417
72
463
102
Needs of society
11
0.0
1

SWITCH
64
110
215
143
Visualize_humans
Visualize_humans
0
1
-1000

SLIDER
23
968
245
1001
magnitude_neg_impact
magnitude_neg_impact
0
100
5.0
5
1
NIL
HORIZONTAL

MONITOR
294
481
505
526
Humans creating a value
count humans with [status_human = \"Value_emergence\"]
17
1
11

MONITOR
519
481
730
526
Humans proceeding to value adaptation
count humans with [status_human = \"Value_adaptation\"]
17
1
11

MONITOR
745
481
955
526
Humans proceeding to value dynamism
count humans with [status_human = \"Value_dynamism\"]
17
1
11

MONITOR
971
481
1182
526
Humans proceeding to innovation
count humans with [status_human = \"Innovate\"]
17
1
11

SWITCH
290
864
708
897
Sizes_of_needs_are_changing_over_time
Sizes_of_needs_are_changing_over_time
0
1
-1000

PLOT
513
908
709
1028
Distribution of size of needs
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"histogram [size_need] of needs" "histogram [size_need] of needs"
PENS
"default" 1.0 1 -16777216 true "" "histogram [size_need] of needs"

SLIDER
290
909
503
942
max_need_change
max_need_change
0
5
5.0
0.5
1
/ 10
HORIZONTAL

SLIDER
290
951
502
984
frequency_of_need_change
frequency_of_need_change
500
5000
1000.0
500
1
ticks
HORIZONTAL

TEXTBOX
29
163
239
181
Number of needs the society has to fulfill:
11
0.0
1

TEXTBOX
29
234
252
260
Preference of the society for value dynamism, value adaptation and innovation:
11
0.0
1

SLIDER
24
437
247
470
Openness_to_change
Openness_to_change
0
100
100.0
5
1
NIL
HORIZONTAL

TEXTBOX
25
403
243
431
Openness of the society towards change (innovation and value changes)
11
0.0
1

TEXTBOX
26
724
206
772
Other variables (for calibration):
18
0.0
1

TEXTBOX
31
23
252
46
----  Model commands  ----
18
0.0
1

TEXTBOX
487
543
1038
572
---------------  Phenomena of value change ---------------
18
0.0
1

TEXTBOX
1300
31
1728
53
--------------- Problem solving capacity ---------------
18
0.0
1

TEXTBOX
292
844
442
862
Resistance to change:
11
0.0
1

TEXTBOX
292
661
442
679
Lock-in:
11
0.0
1

MONITOR
291
678
714
723
Number of ticks since an unacceptable technology was used
Time_since_unacceptable_technology_was_used
17
1
11

TEXTBOX
333
91
407
109
Moral problems
11
0.0
1

MONITOR
291
729
714
774
Maximum duration where no unacceptable technologies have been used
Maximum_time_no_unacceptable_technologies_were_used
17
1
11

TEXTBOX
724
837
874
855
Moral revolutions:
11
0.0
1

PLOT
720
708
1165
828
Number of values
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count values"

PLOT
720
858
1165
978
Change in importance of values
NIL
NIL
0.0
10.0
0.0
0.1
true
false
"set value_change_last_x_ticks [0]" ""
PENS
"default" 1.0 0 -16777216 true "" "plot sum_variance_importance_of_values"

PLOT
1200
62
1821
260
Total number of (perceived) moral problems 
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Total number of moral problems" 1.0 0 -2674135 true "" "plot count moral_problems with [status_moral_problem = \"unaware_problem\"] + count moral_problems with [status_moral_problem = \"aware_problem\"]"
"Number of perceived moral problems" 1.0 0 -13840069 true "" "plot count moral_problems with [status_moral_problem = \"aware_problem\"]"

PLOT
1200
267
1821
475
Number of (unacceptable) technologies in use
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Total number of technologies in use" 1.0 0 -13345367 true "" "plot count technologies with [transported_technology? = false]"
"Number of unacceptable technologies in use" 1.0 0 -2674135 true "" "plot count technologies with [acceptable_technology? = false and transported_technology? = false]"

TEXTBOX
1208
519
2075
983
Main changes to the model in this new version:\n\n1. Relation between moral problems and values\n\n- In the previous version of the model, the relation between moral problems and values was 1 to 1; i.e. a value could only be used to recognize one moral problem (although this moral problem could be caused by different technologies).\n\n- In this new version, a same moral problem can still be caused by different technologies. However, the relation between moral problems and value is 1 to max 3, meaning that a value will recognize a specific combination of up to 3 moral problems. For example, the use of one technology has caused the appearance of two moral problems (e.g. moral problem 1 and moral problem 2). The human using the technology checks if a value exists that is characterized by moral problem 1 and moral problem 2 (and hence will recognized this specific combination of moral problems). Alternatively, the human checks if two distinct values exists of which one is characterized by moral problem 1 and the other by moral problem 2. \nIf the values above do no exist, the human create a new value (characterized by moral problem 1 and 2). If only one value exists (for example one characterized by moral problem 1), the human creates a new value characterized by moral problem 2)\n\n- I feel that this new conceptualisation of the relation between moral problems and values better aligns with the conceptualisation of value change proposed by van de Poel and Kudina paper in 3 ways:\n--- Values emerging are new trully new (i.e. new combination of moral problems)\n--- Does better justice to the function of recognizing moral problems which is fulfilled by values. \n--- The meaning of a value can change over time. One value can be characterized by moral problem 1 and 2, and later by moral problem 1, 2 and 3. By analogy, we could explain how the value of sustainability has changed over time (some stakeholder now also defined sustainability in terms of social justice), or how one specification of privacy has become dominant over time.\n\n2. The visualization :)
13
0.0
1

SWITCH
291
611
442
644
Switch_on_values
Switch_on_values
0
1
-1000

TEXTBOX
292
594
442
612
The inevitability of values:
11
0.0
1

SWITCH
1265
1014
1373
1047
prints_on
prints_on
1
1
-1000

TEXTBOX
615
1046
1043
1088
Moral: big change in which value are considered to be important. And when there are new values, we call this value emergence. So separate both graphs.\nBut also interesting to evaluate how both phenomena relate to each other.
11
0.0
1

SLIDER
885
983
1086
1016
threshold_moral_revolution
threshold_moral_revolution
0
100
35.0
1
1
NIL
HORIZONTAL

MONITOR
721
983
879
1028
Moral revoluation occured?
Moral_revolution_occured_true_false
17
1
11

TEXTBOX
724
692
874
710
Value emergence:
11
0.0
1

MONITOR
290
992
498
1037
NIL
average_duration_problem_solving
17
1
11

SWITCH
21
544
259
577
Fix_values_techs_needs_at_beginning
Fix_values_techs_needs_at_beginning
0
1
-1000

TEXTBOX
729
580
879
598
Lock-situation:
11
0.0
1

MONITOR
721
598
893
643
Ongoing lock-in situtation
lock_in_situtation_true_false
17
1
11

OUTPUT
904
579
1164
682
8

SLIDER
448
611
643
644
Value_memory_of_society
Value_memory_of_society
0
100
85.0
5
1
NIL
HORIZONTAL

SWITCH
722
653
893
686
print_lockins
print_lockins
1
1
-1000

SLIDER
1418
926
1688
959
increase_performance_level_each_use
increase_performance_level_each_use
0.05
1
0.75
0.05
1
NIL
HORIZONTAL

SLIDER
1428
981
1656
1014
factor_increase_moral_problem
factor_increase_moral_problem
0
0.5
0.2
0.05
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

ambulance
false
0
Rectangle -7500403 true true 30 90 210 195
Polygon -7500403 true true 296 190 296 150 259 134 244 104 210 105 210 190
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Circle -16777216 true false 69 174 42
Rectangle -1 true false 288 158 297 173
Rectangle -1184463 true false 289 180 298 172
Rectangle -2674135 true false 29 151 298 158
Line -16777216 false 210 90 210 195
Rectangle -16777216 true false 83 116 128 133
Rectangle -16777216 true false 153 111 176 134
Line -7500403 true 165 105 165 135
Rectangle -7500403 true true 14 186 33 195
Line -13345367 false 45 135 75 120
Line -13345367 false 75 135 45 120
Line -13345367 false 60 112 60 142

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

ball football
false
0
Polygon -7500403 false true 301 133 301 164 275 192 229 224 167 236 137 236 74 224 30 194 3 162 2 138 30 104 76 74 134 62 168 62 228 74 274 105
Polygon -7500403 true true 300 150 300 165 270 195 225 225 163 236 134 236 75 225 30 195 2 162 2 140 30 105 75 75 136 63 165 63 225 75 270 105 300 135
Line -16777216 false 300 155 5 155
Polygon -1 true false 28 193 28 107 51 91 51 209
Rectangle -1 true false 90 150 210 160
Rectangle -1 true false 198 141 205 170
Rectangle -1 true false 183 141 190 170
Rectangle -1 true false 168 141 175 170
Rectangle -1 true false 153 141 160 170
Rectangle -1 true false 138 141 145 170
Rectangle -1 true false 123 141 130 170
Rectangle -1 true false 108 141 115 170
Rectangle -1 true false 93 141 100 170
Polygon -1 true false 272 193 272 107 249 91 249 209

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

campsite
false
0
Polygon -7500403 true true 150 11 30 221 270 221
Polygon -16777216 true false 151 90 92 221 212 221
Line -7500403 true 150 30 150 225

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

computer workstation
false
0
Rectangle -7500403 true true 60 45 240 180
Polygon -7500403 true true 90 180 105 195 135 195 135 210 165 210 165 195 195 195 210 180
Rectangle -16777216 true false 75 60 225 165
Rectangle -7500403 true true 45 210 255 255
Rectangle -10899396 true false 249 223 237 217
Line -16777216 false 60 225 120 225

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

drop
false
0
Circle -7500403 true true 73 133 152
Polygon -7500403 true true 219 181 205 152 185 120 174 95 163 64 156 37 149 7 147 166
Polygon -7500403 true true 79 182 95 152 115 120 126 95 137 64 144 37 150 6 154 165

electric outlet
false
0
Rectangle -7500403 true true 45 0 255 297
Polygon -16777216 false false 120 270 90 240 90 195 120 165 180 165 210 195 210 240 180 270
Rectangle -16777216 true false 169 199 177 236
Rectangle -16777216 true false 169 64 177 101
Polygon -16777216 false false 120 30 90 60 90 105 120 135 180 135 210 105 210 60 180 30
Rectangle -16777216 true false 123 64 131 101
Rectangle -16777216 true false 123 199 131 236
Rectangle -16777216 false false 45 0 255 296

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

food
false
0
Polygon -7500403 true true 30 105 45 255 105 255 120 105
Rectangle -7500403 true true 15 90 135 105
Polygon -7500403 true true 75 90 105 15 120 15 90 90
Polygon -7500403 true true 135 225 150 240 195 255 225 255 270 240 285 225 150 225
Polygon -7500403 true true 135 180 150 165 195 150 225 150 270 165 285 180 150 180
Rectangle -7500403 true true 135 195 285 210

hammer
true
0
Polygon -7500403 true true 76 123 76 120 117 77 121 77 161 90 161 93 133 119 133 122 207 193 207 198 197 208 192 208 121 137 117 137 104 150

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

minus
true
0
Rectangle -7500403 true true 30 120 270 180

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

plus
true
0
Rectangle -7500403 true true 120 30 180 270
Rectangle -7500403 true true 30 120 270 180

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

suit heart
false
0
Circle -7500403 true true 135 43 122
Circle -7500403 true true 43 43 122
Polygon -7500403 true true 255 120 240 150 210 180 180 210 150 240 146 135
Line -7500403 true 150 209 151 80
Polygon -7500403 true true 45 120 60 150 90 180 120 210 150 240 154 135

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

telephone
false
0
Polygon -7500403 true true 75 273 60 255 60 195 84 165 75 165 45 150 45 120 60 90 105 75 195 75 240 90 255 120 255 150 223 165 215 165 240 195 240 255 226 274
Polygon -16777216 false false 75 273 60 255 60 195 105 135 105 120 105 105 120 105 120 120 180 120 180 105 195 105 195 135 240 195 240 255 225 273
Polygon -16777216 false false 81 165 74 165 44 150 44 120 59 90 104 75 194 75 239 90 254 120 254 150 218 167 194 135 194 105 179 105 179 120 119 120 119 105 104 105 104 135 81 166 78 165
Rectangle -16777216 false false 120 165 135 180
Rectangle -16777216 false false 165 165 180 180
Rectangle -16777216 false false 142 165 157 180
Rectangle -16777216 false false 165 188 180 203
Rectangle -16777216 false false 142 188 157 203
Rectangle -16777216 false false 120 188 135 203
Rectangle -16777216 false false 120 210 135 225
Rectangle -16777216 false false 142 210 157 225
Rectangle -16777216 false false 165 210 180 225
Rectangle -16777216 false false 120 233 135 248
Rectangle -16777216 false false 142 233 157 248
Rectangle -16777216 false false 165 233 180 248

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

warning
false
0
Polygon -7500403 true true 0 240 15 270 285 270 300 240 165 15 135 15
Polygon -16777216 true false 180 75 120 75 135 180 165 180
Circle -16777216 true false 129 204 42
Line -7500403 true 135 15 0 240
Line -16777216 false 135 15 165 15
Line -16777216 false 165 15 300 240
Line -16777216 false 285 270 300 240
Line -16777216 false 285 270 15 270
Line -16777216 false 0 240 15 270
Line -16777216 false 0 240 135 15

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
