import { gql, useMutation } from "@apollo/client";
import { Button, useToast } from "@chakra-ui/react";
import { QUERY } from "../Screen";

const ADD_PLAYER = gql`
  mutation AddPlayer($name: String!) {
    createPlayer(name: $name) {
      player {
        id
        name
      }
      errors
    }
  }
`;

const AddPlayerButton = ({ data }) => {
  const toast = useToast();
  const [addPlayer] = useMutation(ADD_PLAYER, {
    update: (
      cache,
      {
        data: {
          createPlayer: { player, errors },
        },
      }
    ) => {
      if (player === null) {
        toast.closeAll();
        toast({
          title: "Failed!",
          description: errors[0],
          status: "error",
          duration: 4000,
          isClosable: true,
          position: "top",
        });
        return false;
      }
      cache.writeQuery({
        query: QUERY,
        data: {
          ...data,
          players: [...data.players, player],
        },
      });
      toast.closeAll();
      toast({
        title: "Player added successfully!",
        status: "success",
        duration: 4000,
        isClosable: true,
        position: "top",
      });
    },
  });

  const handlePlayerAdd = () => {
    const name = prompt("Enter the new player's name");

    if (name !== null && name !== "") {
      addPlayer({ variables: { name } });
    }
  };

  return (
    <Button
      onClick={handlePlayerAdd}
      colorScheme="teal"
      variant="outline"
      mt="15"
    >
      Add player
    </Button>
  );
};

export default AddPlayerButton;
