Feature Complete
------------------
* Bug where Robson doesn't stop moving after ending scene is triggered even when control was disabled; likely to do with `move_and_slide()` in `CharacterBody2D` class?


Coverage
------------------
* Issue with `cast_light()`, where if no `await` for 0.1s is built in, the occlusion doens't work correctly, probably somehow not ready / sequencing issue
* Issue when adding new light that when quickly adding and removing the last light, the game can crash due to "null instance", added hard guardrail to fix, unclear what the cause is
* Issue with translating between mouse position and cell coords: it's impacted by the transform scale and gets a bit messy


Dialog
------------------
* Low-effort ad-hoc implementation of dialog:
  * requires `in_dialog` indicator to prevent pressing space skipping dialog before dialog starts (probably)
  * requires `is_dialog_typing` to prevent gibberish - otherwise two dialog texts will interweave
  * these need to be added in each stage with dialog components


Automated
------------------
* Abandoned coveyer belt implementation:
  * drawing works and belts look good
  * splitter doesn't work somehow - implemented as a changing belt
  * item drawing has issues as it belongs to the belt and belt layer order can't be guaranteed (if next belt is under the previous belt, item image gets cut off)


Functional
------------------
* Flipper implementation took awhile; original implementation with `RigidBody2D` and `PinJoint` did not work, lots of going through collision and wierd pyhysics; eventually the most straightforward way implemented is using tween with `AnimatableBody2D`
* One-way collision at pinball entrance did not work as well, used invisible blocker instead


General
------------------
* Should have implemented a general "stage" class
* Maybe should have a Game root scene and switch scenes in the same scene tree instead of changing scenes between stages? Could be better for audio implementation etc
* Generally things were implemented for convenience as each stage is short
* There is probably a better way to manage scene triggers etc
