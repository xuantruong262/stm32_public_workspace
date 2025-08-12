#ifndef __SNAKE_GAME_H_
#define __SNAKE_GAME_H_

#include <stdlib.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

// For USER DEFINE
#define Size_per_block 2
#define DISPLAY_WIDTH   128
#define DISPLAY_HEIGHT  160
#define OBJECTS_THICKNESS 2

// For Privite DEFINE
#define Is_up_active 0
#define Is_right_active  1
#define Is_down_active  2
#define Is_left_active  3
#define LEN(x) x*Size_per_block
#define BIT_PER_BYTE 8
#define HEIGHT_IN_TABLE DISPLAY_HEIGHT/OBJECTS_THICKNESS
#define WIDTH_IN_TABLE (DISPLAY_WIDTH/OBJECTS_THICKNESS)
#define WIDTH_IN_BYTE (WIDTH_IN_TABLE/BIT_PER_BYTE)
//Declare private typedef
typedef enum ekey {
	emUp,
	emRight,
	emDown,
	emLeft,
	emNone
}ekey;

typedef enum branch_direction {
	emD_Up,
	emD_Right,
	emD_Down,
	emD_Left,
}branch_direction;

typedef struct branch_info {
	uint8_t branch_lenght;
	branch_direction dir;
}branch_info;

typedef enum ehead_status{
  emHead_free,
  emHit_the_Wall,
  emEat
} ehead_status;

typedef struct  {
	uint8_t x;
	uint8_t y;
}object_location;

typedef struct 
{
  object_location position_in_table;
  uint8_t width;
  uint8_t height;
  uint16_t color;
} obj_status;

typedef struct {
  uint8_t pos_x;
  uint8_t pos_y;
  uint8_t width;
  uint8_t height;
  uint16_t color;
}Snake_Object_location;

typedef Snake_Object_location Cherry;

typedef struct Snake{
  Snake_Object_location valid_space;
  Snake_Object_location boder;
  Snake_Object_location snake;
  Snake_Object_location snake_head;
  Snake_Object_location snake_tail;
  Snake_Object_location snake_rmv;
  ehead_status IsDeath;
  void (* Init_border)     (struct Snake *my_snake);
  void (* Init_valid_space)(struct Snake *my_snake);
  void (* Snake_Init_Shape)(struct Snake *my_snake);
}Snake;


// Declare Variable

extern uint8_t Box[HEIGHT_IN_TABLE][WIDTH_IN_BYTE];
extern ekey control;
extern uint8_t total_branch;
extern branch_info* branch;
extern obj_status Obj_tail;
extern obj_status Obj_head;
extern obj_status Obj_RMV;
extern ehead_status Is_death;
extern Cherry Cherry_In_table;
// Declare Function
void setbit(uint8_t bit_num, uint8_t status, uint8_t* addr);
uint8_t getbit(uint8_t bit_num, uint8_t* addr);
ehead_status Snake_Head_update(object_location *head);
void Snake_Tail_update(object_location* tail, branch_info *info);
void Snake_Remover_update(object_location* RMV, object_location tail_before_update);
void Snake_Update_branch(branch_info** bran, uint8_t *Total_branch);
//public func
void Cherry_Control(Cherry *ch);
void Get_Cherry(Cherry *ch);
void Snake_Control(Snake *my_snake, ekey *Key);
void Init(Snake *my_snake);
void Init_border(Snake *my_snake);
void Init_valid_space(Snake *my_snake);
void Snake_Init_Shape(Snake *my_snake);

#ifdef __cplusplus
}
#endif

#endif 