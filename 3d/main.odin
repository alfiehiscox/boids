package main

import rl "vendor:raylib"

WINDOW_WIDTH :: 1000
WINDOW_HEIGHT :: 800

SPACE_DIMS :: 600

Boid :: struct {
	id:    int,
	pos:   rl.Vector3,
	vel:   rl.Vector3,
	rot:   f32,
	color: rl.Color,
}

main :: proc() {
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "3D Boids")
	defer rl.CloseWindow()
	rl.SetTargetFPS(60)

	camera := rl.Camera3D {
		position   = {100, 100, 100},
		target     = {0, 0, 0},
		up         = {0, 1, 0},
		fovy       = 45,
		projection = rl.CameraProjection.PERSPECTIVE,
	}

	boid := Boid {
		id    = 0,
		pos   = {0, 0, 0},
		vel   = {0, 1, 0},
		rot   = 0,
		color = rl.RED,
	}

	cube := rl.Vector3{0, 0, 0}
	rl.DisableCursor()

	for !rl.WindowShouldClose() {
		_ = rl.GetFrameTime()

		rl.UpdateCamera(&camera, rl.CameraMode.FREE)
		if rl.IsKeyPressed(rl.KeyboardKey.Z) {camera.target = {0, 0, 0}}

		update_boid(&boid)

		rl.BeginDrawing()
		defer rl.EndDrawing()

		rl.ClearBackground(rl.RAYWHITE)

		{
			rl.BeginMode3D(camera)
			defer rl.EndMode3D()

			draw_boid(boid)
		}
	}
}

draw_boid :: proc(boid: Boid) {
	rl.DrawCylinder(boid.pos, 0, 1, 2, 12, boid.color)
	rl.DrawCylinderWires(boid.pos, 0, 1, 2, 12, rl.BLACK)
}

update_boid :: proc(boid: ^Boid) {
	boid.pos += boid.vel
}
