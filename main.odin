package main

import "core:fmt"
import "core:math"
import "core:math/linalg"
import "core:math/rand"
import rl "vendor:raylib"

WINDOW_WIDTH :: 800
WINDOW_HEIGHT :: 600

BOID_SIZE :: 7
BOID_VELOCITY_MAX :: 400
BOID_VELOCITY_MIN :: -400

BOID_TURN_THRESHOLD :: 40
BOID_TURN_STRENGTH :: 30

BOID_VISION_RADIUS :: 50
BOID_FIELD_OF_VIEW :: 120

BOID_COHESION :: 10

Boid :: struct {
	position: rl.Vector2,
	velocity: rl.Vector2,
	rotation: f32,
	color:    rl.Color,
}

main :: proc() {
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "boids")
	defer rl.CloseWindow()

	rl.SetTargetFPS(60)

	middle_x := f32(WINDOW_WIDTH / 2)
	middle_y := f32(WINDOW_HEIGHT / 2)

	boids := [30]Boid{}
	for _, i in boids {
		boids[i] = random_boid()
	}
	boids[0].color = rl.RED

	for !rl.WindowShouldClose() {
		delta := rl.GetFrameTime()

		for &boid, i in boids {
			update_boid(&boid, delta)
			check_boid_collisions(&boid, i, boids[:])
		}

		{
			rl.BeginDrawing()
			defer rl.EndDrawing()
			rl.ClearBackground(rl.BLACK)

			rl.DrawFPS(30, 30)

			for boid in boids {
				draw_boid(boid)
			}
		}
	}
}

random_boid :: proc() -> Boid {
	return Boid {
		position = random_vec_2(0, WINDOW_WIDTH, 0, WINDOW_HEIGHT),
		velocity = random_vec_2(
			BOID_VELOCITY_MIN,
			BOID_VELOCITY_MAX,
			BOID_VELOCITY_MIN,
			BOID_VELOCITY_MAX,
		),
		rotation = rand.float32_range(0, 360),
		color = rl.WHITE,
	}
}

random_vec_2 :: proc(minx, maxx, miny, maxy: f32) -> rl.Vector2 {
	x := rand.float32_range(minx, maxx)
	y := rand.float32_range(miny, maxy)
	return {x, y}
}

draw_boid :: proc(boid: Boid) {
	//if boid.color == rl.RED {
	//	rl.DrawCircleV(boid.position, BOID_VISION_RADIUS, rl.BLUE)
	//}
	rl.DrawPoly(boid.position, 3, BOID_SIZE, boid.rotation, boid.color)
}

update_boid :: proc(boid: ^Boid, delta: f32) {
	boid.position.x += boid.velocity.x * delta
	boid.position.y += boid.velocity.y * delta
	boid.rotation = math.atan2(boid.velocity.y, boid.velocity.x) * (180 / math.PI)
}

check_boid_collisions :: proc(boid: ^Boid, i: int, boids: []Boid) {
	target_velocity := boid.velocity

	if boid.position.x < BOID_TURN_THRESHOLD {
		target_velocity.x += BOID_TURN_STRENGTH
	} else if boid.position.x > WINDOW_WIDTH - BOID_TURN_STRENGTH {
		target_velocity.x -= BOID_TURN_STRENGTH
	}

	if boid.position.y < BOID_TURN_THRESHOLD {
		target_velocity.y += BOID_TURN_STRENGTH
	} else if boid.position.y > WINDOW_HEIGHT - BOID_TURN_STRENGTH {
		target_velocity.y -= BOID_TURN_STRENGTH
	}

	// TODO: have another look at this, not sure it's right
	// avoidance behaviour
	// avoidance_vector := rl.Vector2{0, 0}
	// boid_direction := linalg.normalize(boid.velocity)
	// for other_boid, ix in boids {
	// 	if ix == i {continue}

	// 	dist := rl.Vector2Distance(boid.position, other_boid.position)
	// 	if dist < BOID_TURN_THRESHOLD {
	// 		to_neighbour := linalg.normalize(other_boid.position - boid.position)
	// 		product := rl.Vector2DotProduct(boid_direction, to_neighbour)
	// 		angle := math.acos(product)

	// 		if angle < BOID_FIELD_OF_VIEW * (math.PI / 180.0) {
	// 			force := to_neighbour * (-1 / dist)
	// 			avoidance_vector += force
	// 		}
	// 	}
	// }
	// target_velocity += avoidance_vector

	sum := rl.Vector2{0, 0}
	for other_boid in boids {
		sum += other_boid.position
	}

	// cohesion behaviour 
	if sum != 0 {
		avg := sum / f32(len(boids))
		cohesion := linalg.normalize(avg - boid.position)
		target_velocity += cohesion * BOID_COHESION
	}

	// Obey;max;and;min;velocities
	target_length := rl.Vector2Length(target_velocity)
	if target_length > BOID_VELOCITY_MAX {
		target_velocity = linalg.normalize(target_velocity) * BOID_VELOCITY_MAX
	}

	if target_length < BOID_VELOCITY_MIN {
		target_velocity = linalg.normalize(target_velocity) * BOID_VELOCITY_MIN
	}

	boid.velocity = linalg.lerp(boid.velocity, target_velocity, 0.3)
	// boid.velocity = target_velocity
}
