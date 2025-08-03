# Input
- [x] controller connection

# World
- [ ] tilemap

# Movement
- [x] wall hang/slide
  - [x] fix hang to the left - offset from wall
  - [ ] fix hang below and above edge of wall
- [ ] update collision shape for each animation
  - as necessary

# Attacks
- [x] attack states
  - [ ] only float if attacks connect? otherwise just fall?
- [x] dash attack
- [ ] enemy
- [ ] hitboxes
- [ ] hurtboxes

# Refactors
- [x] PlayerState -> MovementState
- [x] DirectionDetector node (detect facing left or right)
