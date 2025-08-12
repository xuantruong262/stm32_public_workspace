#include "snake_game.h"


uint8_t Box[HEIGHT_IN_TABLE][WIDTH_IN_BYTE];
uint8_t total_branch;
branch_info* branch;
obj_status Obj_tail;
obj_status Obj_head;
obj_status Obj_RMV;
ehead_status Is_death;
Cherry Cherry_In_table;

void setbit(uint8_t bit_num, uint8_t status, uint8_t* addr) {
	uint8_t byte_pos = bit_num / 8;
	uint8_t bit_in_byte = bit_num - byte_pos*8;
	uint8_t* addr_to_byte_pos = addr + byte_pos;
	if (status) {
		*addr_to_byte_pos |= 1 << (7 - bit_in_byte);
	}
	else {
		*addr_to_byte_pos &= ~(1 << (7 - bit_in_byte));
	}
	
}

uint8_t getbit(uint8_t bit_num, uint8_t* addr) {
	uint8_t value = 0;
	uint8_t byte_pos = bit_num / 8;
	uint8_t bit_in_byte = bit_num - byte_pos * 8;
	uint8_t* addr_to_byte_pos = addr + byte_pos;
	value = *addr_to_byte_pos & (1 << (7 - bit_in_byte));
	return value ? 1 : 0;
}


void Init_border(Snake *my_snake)
{
    my_snake->boder.color = 0xf67a;
    my_snake->boder.pos_x = 0;
    my_snake->boder.pos_y = 0;
    my_snake->boder.width  = DISPLAY_WIDTH;
    my_snake->boder.height = DISPLAY_HEIGHT;
    // return m_obj;
}

void Init_valid_space(Snake *my_snake)
{
    my_snake->valid_space.color = 0x0000;
    my_snake->valid_space.pos_x = OBJECTS_THICKNESS;
    my_snake->valid_space.pos_y = OBJECTS_THICKNESS;
    my_snake->valid_space.width  = DISPLAY_WIDTH - OBJECTS_THICKNESS*2;
    my_snake->valid_space.height = DISPLAY_HEIGHT - OBJECTS_THICKNESS*2;
}

void Snake_Init_Shape(Snake *my_snake){
  Obj_tail.position_in_table.x = 1;
  Obj_tail.position_in_table.y = 1;

  Obj_head.position_in_table.x = 7;
  Obj_head.position_in_table.y = 1;

  Obj_RMV.position_in_table.x = 0;
  Obj_RMV.position_in_table.y = 0;

  for(uint8_t i = 1 ; i < branch->branch_lenght+1;i++){
    setbit(i,1,Box[1]);
  }
  my_snake->snake.pos_x = Obj_tail.position_in_table.x * Size_per_block;
  my_snake->snake.pos_y = Obj_tail.position_in_table.y * Size_per_block;
  my_snake->snake.width = Obj_head.position_in_table.x * OBJECTS_THICKNESS - 1;
  my_snake->snake.height = OBJECTS_THICKNESS;
  my_snake->snake.color = Obj_tail.color;
}
void Init(Snake *my_snake) {
	for (int i = 0; i < HEIGHT_IN_TABLE; ++i) { // O(n)
		int j = 0;
			if ( (i == 0) || (i == HEIGHT_IN_TABLE-1)) {
				memset(Box[i],0xff,WIDTH_IN_BYTE);
        continue;
			}
    setbit(j,1,Box[i]);
		for (j = 1; j < WIDTH_IN_TABLE-1; ++j) {
				setbit(j,0,Box[i]);
		}
		setbit(j,1,Box[i]);
	}
    Obj_tail = (obj_status){
        .position_in_table = {.x = 1, .y = 1},
        .width = 2,
        .height = 2,
        .color = 0xf7e0};

    Obj_head = (obj_status){
        .position_in_table = {.x = 7, .y = 1},
        .width = 2,
        .height = 2,
        .color = 0xf7e0};
    Obj_RMV = (obj_status){
        .position_in_table = {.x = 0, .y = 0},
        .width = 2,
        .height = 2,
        .color = 0x0000};
    total_branch = 1;

    //First snake branch
    branch = (branch_info*)malloc(total_branch * sizeof(branch_info));
    branch[0].branch_lenght = 7;
    branch[0].dir = emD_Right;
    my_snake->snake_head.pos_x  = Obj_head.position_in_table.x * Size_per_block;
    my_snake->snake_head.pos_y  = Obj_head.position_in_table.y * Size_per_block;
    my_snake->snake_head.width  = Obj_head.width * Size_per_block;
    my_snake->snake_head.height = Obj_head.height * Size_per_block;
    my_snake->snake_head.color  = Obj_head.color;

    my_snake->snake_tail.pos_x  = Obj_tail.position_in_table.x * Size_per_block;
    my_snake->snake_tail.pos_y  = Obj_tail.position_in_table.y * Size_per_block;
    my_snake->snake_tail.width  = Obj_tail.width * Size_per_block;
    my_snake->snake_tail.height = Obj_tail.height * Size_per_block;
    my_snake->snake_tail.color  = Obj_tail.color;

    my_snake->snake_rmv.pos_x  = Obj_RMV.position_in_table.x * Size_per_block;
    my_snake->snake_rmv.pos_y  = Obj_RMV.position_in_table.y * Size_per_block;
    my_snake->snake_rmv.width  = Obj_RMV.width * Size_per_block;
    my_snake->snake_rmv.height = Obj_RMV.height * Size_per_block;
    my_snake->snake_rmv.color  = Obj_RMV.color;

    // // Assign Function pointer
    my_snake->Init_border       = Init_border;
    my_snake->Init_valid_space  =  Init_valid_space;
    my_snake->Snake_Init_Shape  =  Snake_Init_Shape;

}


ehead_status Snake_Head_update(object_location *head) {
  if ((head->y == Cherry_In_table.pos_y) ||
      (head->y == Cherry_In_table.pos_y + 1) ||
      (head->y == Cherry_In_table.pos_y + 2))
  {
    if ((head->x == Cherry_In_table.pos_x) ||
        (head->x == Cherry_In_table.pos_x + 1) ||
        (head->x == Cherry_In_table.pos_x + 2))
    {
      setbit((Cherry_In_table.pos_x)  ,0,  Box[ Cherry_In_table.pos_y]);
      setbit((Cherry_In_table.pos_x)+1,0,Box[ Cherry_In_table.pos_y]);
      setbit((Cherry_In_table.pos_x)+2,0,Box[ Cherry_In_table.pos_y]);

      setbit((Cherry_In_table.pos_x)  ,0,  Box[(Cherry_In_table.pos_y)+1]);
      setbit((Cherry_In_table.pos_x)+1,0,Box[(Cherry_In_table.pos_y)+1]);
      setbit((Cherry_In_table.pos_x)+2,0,Box[(Cherry_In_table.pos_y)+1]);

      setbit((Cherry_In_table.pos_x)  ,0,  Box[(Cherry_In_table.pos_y)+2]);
      setbit((Cherry_In_table.pos_x)+1,0,Box[(Cherry_In_table.pos_y)+2]);
      setbit((Cherry_In_table.pos_x)+2,0,Box[(Cherry_In_table.pos_y)+2]);
      setbit(head->x ,1,Box[head->y]);
      return emEat;
    }
  }
  else if (getbit(head->x, Box[head->y]))
  {
    return emHit_the_Wall;
  }
  setbit(head->x, 1, Box[head->y]);
	return emHead_free;
}

void Snake_Tail_update(object_location* tail, branch_info *info) {
	uint8_t checker[4] = { 0,0,0,0 };
	uint8_t around_locate[4] = { tail->y - 1,tail->x + 1,tail->y + 1,tail->x - 1 }; ///up,right,down,left
	if (around_locate[0] > 0) {
		checker[emD_Up] = getbit(tail->x, Box[around_locate[0]]);
	}
	if (around_locate[1] > 0) {
		checker[emD_Right] = getbit(around_locate[1], Box[tail->y]);
	}
	if (around_locate[2] > 0) {
		checker[emD_Down] = getbit(tail->x, Box[around_locate[2]]);
	}
	if (around_locate[3] > 0) {
		checker[emD_Left] = getbit(around_locate[3], Box[tail->y]);
	}

	if ( (checker[Is_up_active] > 0) && (info[0].dir == emD_Up) ) {
		tail->y = tail->y - 1;
	}
	if ( (checker[Is_right_active] > 0) && (info[0].dir == emD_Right)) {
		tail->x = tail->x + 1;
	}
	if ( (checker[Is_down_active] > 0) && (info[0].dir == emD_Down)) {
		tail->y = tail->y + 1;
	}
	if ( (checker[Is_left_active] > 0) && (info[0].dir == emD_Left)) {
		tail->x = tail->x - 1;
	}
	setbit(tail->x, 1, Box[tail->y]);
}

void Snake_Remover_update(object_location* RMV, object_location tail_before_update) {
	RMV->x = tail_before_update.x;
	RMV->y = tail_before_update.y;
	setbit(RMV->x, 0, Box[RMV->y]);
}

void Snake_Update_branch(branch_info** bran, uint8_t *Total_branch) {
  uint8_t br = *Total_branch;
	uint8_t hehe = (*Total_branch - 1);
	uint8_t hoho = hehe * sizeof(branch_info);
	if (br > 1) {
		bran[0][br - 1].branch_lenght += 1;
		bran[0][0].branch_lenght -= 1;

		if (bran[0][0].branch_lenght == 0) {
			memcpy(bran[0], bran[0] + 1, hehe * sizeof(branch_info));
			branch_info *tmp = (branch_info*)realloc(bran[0], hoho);
			if (tmp != NULL) {
				bran[0] = tmp;
			}
			*Total_branch = *Total_branch - 1;
		}
	}
}
void Snake_Control(Snake *my_snake, ekey *Key){
      if (branch[total_branch - 1].dir != *Key)
      {
        if (((branch[total_branch - 1].dir + *Key) % 2) != 0)
        {
          total_branch += 1;
          branch = realloc(branch, total_branch * sizeof(branch_info));
          memset(branch + total_branch - 1, 0, sizeof(branch_info));
          branch[total_branch - 1].dir = *Key;
        }
      }
      else{
        branch[total_branch - 1].dir = *Key;
      }


      Snake_Update_branch(&branch, &total_branch);
      if (branch[total_branch - 1].dir == emD_Up)
      {
        Obj_head.position_in_table.x = Obj_head.position_in_table.x;
        Obj_head.position_in_table.y = Obj_head.position_in_table.y - 1;
        Is_death = Snake_Head_update(&Obj_head.position_in_table);
        my_snake->IsDeath = Is_death;
        if(my_snake->IsDeath != emEat){
          Snake_Remover_update(&Obj_RMV.position_in_table, Obj_tail.position_in_table);
          Snake_Tail_update(&Obj_tail.position_in_table, branch);
        }
        else{
          Cherry_In_table.pos_x = 0;
          Cherry_In_table.pos_y = 0;
          branch[total_branch - 1].branch_lenght +=1;
          if(total_branch > 1){
            branch[0].branch_lenght +=1;
          }
        }
      }
      else if (branch[total_branch - 1].dir == emD_Right)
      {
        Obj_head.position_in_table.x = Obj_head.position_in_table.x + 1;
        Obj_head.position_in_table.y = Obj_head.position_in_table.y;
        Is_death = Snake_Head_update(&Obj_head.position_in_table);
        my_snake->IsDeath = Is_death;
        if(my_snake->IsDeath != emEat){
          Snake_Remover_update(&Obj_RMV.position_in_table, Obj_tail.position_in_table);
          Snake_Tail_update(&Obj_tail.position_in_table, branch);
        }
        else{
          Cherry_In_table.pos_x = 0;
          Cherry_In_table.pos_y = 0;
          branch[total_branch - 1].branch_lenght +=1;
          if(total_branch > 1){
            branch[0].branch_lenght +=1;
          }
        }
      }
      else if (branch[total_branch - 1].dir == emD_Down)
      {
        Obj_head.position_in_table.x = Obj_head.position_in_table.x;
        Obj_head.position_in_table.y = Obj_head.position_in_table.y + 1;
        Is_death = Snake_Head_update(&Obj_head.position_in_table);
        my_snake->IsDeath = Is_death;
        if(my_snake->IsDeath != emEat){
          Snake_Remover_update(&Obj_RMV.position_in_table, Obj_tail.position_in_table);
          Snake_Tail_update(&Obj_tail.position_in_table, branch);
        }
        else{
          Cherry_In_table.pos_x = 0;
          Cherry_In_table.pos_y = 0;
          branch[total_branch - 1].branch_lenght +=1;
          if(total_branch > 1){
            branch[0].branch_lenght +=1;
          }
        }
      }
      else if (branch[total_branch - 1].dir == emLeft)
      {
        Obj_head.position_in_table.x = Obj_head.position_in_table.x - 1;
        Obj_head.position_in_table.y = Obj_head.position_in_table.y;
        Is_death = Snake_Head_update(&Obj_head.position_in_table);
        my_snake->IsDeath = Is_death;
        if(my_snake->IsDeath != emEat){
          Snake_Remover_update(&Obj_RMV.position_in_table, Obj_tail.position_in_table);
          Snake_Tail_update(&Obj_tail.position_in_table, branch);
        }
        else{
          Cherry_In_table.pos_x = 0;
          Cherry_In_table.pos_y = 0;
          branch[total_branch - 1].branch_lenght +=1;
          if(total_branch > 1){
            branch[0].branch_lenght +=1;
          }
        }
      }
      if (Is_death == emHit_the_Wall)
      {
        free(branch);
        total_branch = 1;
        branch[0].branch_lenght = 7;
        branch[0].dir = emD_Right;
        Init(my_snake);
        my_snake->IsDeath = Is_death;
        Init_valid_space(my_snake);
        Snake_Init_Shape(my_snake);
        *Key = emD_Right;
      }
      else
      {
        my_snake->snake_head.pos_x  = Obj_head.position_in_table.x * Size_per_block;
        my_snake->snake_head.pos_y  = Obj_head.position_in_table.y * Size_per_block;
        my_snake->snake_head.width  = Obj_head.width;
        my_snake->snake_head.height = Obj_head.height;

        my_snake->snake_tail.pos_x  = Obj_tail.position_in_table.x * Size_per_block;
        my_snake->snake_tail.pos_y  = Obj_tail.position_in_table.y * Size_per_block;
        my_snake->snake_tail.width  = Obj_tail.width  ;
        my_snake->snake_tail.height = Obj_tail.height ;

        my_snake->snake_rmv.pos_x  = Obj_RMV.position_in_table.x * Size_per_block;
        my_snake->snake_rmv.pos_y  = Obj_RMV.position_in_table.y * Size_per_block;
        my_snake->snake_rmv.width  = Obj_RMV.width  ;
        my_snake->snake_rmv.height = Obj_RMV.height ;
      }
}

void Cherry_Control(Cherry *cherry){
  Cherry_In_table.pos_x = cherry->pos_x>>1;
  Cherry_In_table.pos_y = cherry->pos_y>>1;
  Cherry_In_table.width = 3;
  Cherry_In_table.height = 3;
  cherry->color  = 0xf800;
  setbit((cherry->pos_x>>1),1,  Box[cherry->pos_y>>1]);
  setbit((cherry->pos_x>>1)+1,1,Box[cherry->pos_y>>1]);
  setbit((cherry->pos_x>>1)+2,1,Box[cherry->pos_y>>1]);

  setbit((cherry->pos_x>>1),1,  Box[(cherry->pos_y>>1)+1]);
  setbit((cherry->pos_x>>1)+1,1,Box[(cherry->pos_y>>1)+1]);
  setbit((cherry->pos_x>>1)+2,1,Box[(cherry->pos_y>>1)+1]);

  setbit((cherry->pos_x>>1),1,  Box[(cherry->pos_y>>1)+2]);
  setbit((cherry->pos_x>>1)+1,1,Box[(cherry->pos_y>>1)+2]);
  setbit((cherry->pos_x>>1)+2,1,Box[(cherry->pos_y>>1)+2]);
  cherry->width  = 3*Size_per_block;
  cherry->height = 3*Size_per_block;
}

void Get_Cherry(Cherry *cherry){
  cherry->color = 0x0000;
}